import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:keep_links/core/analytics/app_analytics.dart';
import 'package:keep_links/core/utils/app_defaults.dart';
import 'package:keep_links/core/data/database/entity/folder.dart';
import 'package:keep_links/core/data/database/entity/tag.dart';
import 'package:keep_links/core/data/database/entity/url.dart';
import 'package:keep_links/core/data/database/exception/folder_not_found_exception.dart';
import 'package:keep_links/core/data/database/exception/tag_not_found_exception.dart';
import 'package:keep_links/core/data/database/url_store.dart';
import 'package:keep_links/features/developer_options/constants/constants.dart';
import 'package:keep_links/features/developer_options/cubit/developer_options_state.dart';
import 'package:keep_links/features/logger/logger.dart';
import 'package:keep_links/features/settings/service/app_settings_service.dart';

class DeveloperOptionsCubit extends Cubit<DeveloperOptionsState> {
  DeveloperOptionsCubit({
    required AppSettingsService appSettingsService,
    required AppAnalytics appAnalytics,
    required UrlStore Function() urlStoreProvider,
  }) : _appSettingsService = appSettingsService,
       _appAnalytics = appAnalytics,
       _urlStoreProvider = urlStoreProvider,
       super(DeveloperOptionsState(isMockStore: UrlStoreSwitcher.isMock));

  final AppSettingsService _appSettingsService;
  final AppAnalytics _appAnalytics;

  /// Resolved on every use so the store picked by [setMockStore] is used.
  final UrlStore Function() _urlStoreProvider;

  void setMockStore(bool useMock) {
    if (useMock) {
      UrlStoreSwitcher.useMock();
    } else {
      UrlStoreSwitcher.useReal();
    }
    emit(
      state.copyWith(
        isMockStore: UrlStoreSwitcher.isMock,
        action: ShowToast(
          useMock
              ? 'Switched to Mock URL Store'
              : 'Switched to Database URL Store',
        ),
      ),
    );
  }

  /// Seeds initial database records, then prints the database state.
  Future<void> initialDatabaseSetup() async {
    final urlStore = _urlStoreProvider();
    // Names of the seeded folders and tags by id, for the not-found toasts.
    final folderNames = <int, String>{};
    final tagNames = <int, String>{};
    try {
      await _seedDatabase(urlStore, folderNames, tagNames);
      emit(
        state.copyWith(action: const ShowToast('Database seeded successfully')),
      );
    } on FolderNotFoundException catch (e, st) {
      final name = folderNames[e.folderId] ?? 'Unknown';
      _onSeedFailed('$name Folder does not exist', e, st);
    } on TagNotFoundException catch (e, st) {
      final name = tagNames[e.tagId] ?? 'Unknown';
      _onSeedFailed('$name Tag does not exist', e, st);
    } catch (e, st) {
      _onSeedFailed(
        'Something wrong happened while creating Seed database: $e',
        e,
        st,
      );
    }
    await _printDatabase(urlStore);
  }

  /// Clears the store and fills it with development records.
  ///
  /// `createUrl` only accepts existing folder and tag ids, so the folders and
  /// tags are inserted first, and their names recorded in [folderNames] and
  /// [tagNames]. The default folder and tags are restored at the end, since
  /// clearing removes them.
  ///
  /// Each seeded URL is randomly marked as trash or not.
  Future<void> _seedDatabase(
    UrlStore urlStore,
    Map<int, String> folderNames,
    Map<int, String> tagNames,
  ) async {
    final random = Random();

    Future<int> insertFolder(String name) async {
      final id = await urlStore.insertFolder(Folder(folderName: name));
      folderNames[id] = name;
      return id;
    }

    Future<int> insertTag(String name) async {
      final id = await urlStore.insertTag(Tag(tagName: name));
      tagNames[id] = name;
      return id;
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    await urlStore.clearAll();

    final tagIds = <int>[];
    for (final name in seedTagNames) {
      tagIds.add(await insertTag(name));
    }

    var index = 0;
    for (final MapEntry(key: folderName, value: links)
        in seedLinksByFolder.entries) {
      final folderId = await insertFolder(folderName);
      for (final link in links) {
        // Increasing, so each folder's first link is the first one listed.
        final createdAt = now + index;
        await urlStore.createUrl(
          url: Url(
            url: link.url,
            title: link.title,
            metaImageUrl: '${link.url}/og.png',
            metaDescription: 'Description of ${link.title}',
            folderId: folderId,
            createdAt: createdAt,
            updatedAt: createdAt,
            isFavorite: false,
            trash: random.nextBool(),
          ),
          // Between 0 and 3 tags per link.
          tagIds: List.generate(
            index % 4,
            (offset) => tagIds[(index + offset) % tagIds.length],
          ),
        );
        index++;
      }
    }
    await urlStore.seedDefaultFolderIfNotExist();
    await urlStore.seedDefaultTagsIfNotExist();
  }

  void _onSeedFailed(String message, Object error, StackTrace stackTrace) {
    logError(
      'Something wrong happened while creating Seed database',
      error,
      stackTrace: stackTrace,
    );
    emit(state.copyWith(action: ShowToast(message)));
  }

  /// Sets default app theme, language, and retention period.
  Future<void> initialAppSettings() async {
    try {
      await _appSettingsService.saveAppTheme(AppDefaults.appTheme);
      await _appSettingsService.saveLanguage(AppDefaults.appLanguage);
      await _appSettingsService.saveTrashRetention(AppDefaults.trashRetention);
      emit(state.copyWith(action: const ShowToast('App settings initialized')));
    } catch (e, st) {
      logError('Failed to initialize app settings', e, stackTrace: st);
      emit(
        state.copyWith(
          action: const ShowToast('Error While Initializing App Settings'),
        ),
      );
    }
  }

  /// Sends a test event to every analytics client.
  ///
  /// [AppAnalytics] catches and logs each client's errors itself.
  Future<void> onTestAnalyticsClicked() async {
    _appAnalytics.onTestAnalyticsClicked();
  }

  void actionHandled() => emit(state.copyWith(clearAction: true));

  /// Prints current database contents to the debug console.
  ///
  /// Debug-console output only, so failures show a debug-only toast.
  Future<void> _printDatabase(UrlStore urlStore) async {
    try {
      final folders = await urlStore.findAllFolders().first;
      final urls = await urlStore.findAllUrl().first;
      final tags = await urlStore.findAllTags().first;
      final urlTags = await urlStore.findAllUrlTags().first;

      debugPrint('--- FOLDERS (${folders.length}) ---');
      for (final f in folders) {
        debugPrint('id=${f.id}, name=${f.folderName}');
      }

      debugPrint('--- URLS (${urls.length}) ---');
      for (final u in urls) {
        final urlId = u.id;
        final folder = urlId != null
            ? await urlStore.findFolderForUrlId(urlId)
            : null;
        debugPrint(
          'id=${u.id}, title=${u.title}, url=${u.url}, '
          'folderId=${u.folderId} (${folder?.folderName}), '
          'isFavorite=${u.isFavorite}, createdAt=${u.createdAt}, trash=${u.trash}',
        );
      }

      debugPrint('--- TAGS (${tags.length}) ---');
      for (final t in tags) {
        debugPrint('id=${t.id}, name=${t.tagName}');
      }

      debugPrint('--- URL_TAG (${urlTags.length}) ---');
      for (final ut in urlTags) {
        debugPrint('urlId=${ut.urlId}, tagId=${ut.tagId}');
      }
    } catch (e, st) {
      logError(
        'Failed to print database',
        e,
        stackTrace: st,
        isShowToastInDebug: true,
      );
    }
  }
}
