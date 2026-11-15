import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:mindful_links/core/data/database/entity/folder.dart';
import 'package:mindful_links/core/data/database/entity/tag.dart';
import 'package:mindful_links/core/data/database/entity/url.dart';
import 'package:mindful_links/core/data/database/url_store.dart';
import 'package:mindful_links/core/app_defaults.dart';
import 'package:mindful_links/features/logger/logger.dart';
import 'package:mindful_links/features/settings/service/app_settings_service.dart';
import 'package:mindful_links/utils/utils.dart';

class DeveloperOptionsService {
  /// Seeds initial database records and prints database state.
  static Future<void> initialDatabaseSetup({UrlStore? store}) async {
    final urlStore = store ?? GetIt.instance.get<UrlStore>();

    try {
      await seedDatabase(urlStore);
      Utils.showToast('Database seeded successfully');
    } catch (e, st) {
      logError(
        'Something wrong happened while creating Seed database',
        e,
        stackTrace: st,
      );
      Utils.showToast(
        'Something wrong happened while creating Seed database: $e',
      );
    } finally {
      await printDatabase(urlStore);
    }
  }

  /// Sets default app theme, language, and retention period.
  static Future<void> initialAppSettings({AppSettingsService? service}) async {
    final settingsService = service ?? GetIt.instance.get<AppSettingsService>();
    await settingsService.saveAppTheme(AppDefaults.appTheme);
    await settingsService.saveLanguage(AppDefaults.appLanguage);
    await settingsService.saveTrashRetention(AppDefaults.trashRetention);
    Utils.showToast('App settings initialized');
  }

  /// Populates the URL store with initial development records.
  static Future<void> seedDatabase(UrlStore urlStore) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final flutterFolder = Folder(folderName: 'Flutter Resources');
    final dbFolder = Folder(folderName: 'Database Resources');

    final records = <UrlRecord>[
      (
        Url(
          url: 'https://flutter.dev',
          title: 'Flutter',
          metaImageUrl: 'https://flutter.dev/og.png',
          metaDescription: 'Description of Flutter',
          createdAt: now,
          updatedAt: now,
          isFavorite: false,
        ),
        flutterFolder,
        [Tag(tagName: 'flutter'), Tag(tagName: 'dart'), Tag(tagName: 'mobile')],
      ),
      (
        Url(
          url: 'https://dart.dev',
          title: 'Dart',
          metaImageUrl: 'https://dart.dev/og.png',
          metaDescription: 'Description of Dart',
          createdAt: now,
          updatedAt: now,
          isFavorite: false,
        ),
        flutterFolder,
        [
          Tag(tagName: 'mobile'),
          Tag(tagName: 'database'),
          Tag(tagName: 'tutorial'),
        ],
      ),
      (
        Url(
          url: 'https://pub.dev',
          title: 'pub.dev',
          metaImageUrl: 'https://pub.dev/og.png',
          metaDescription: 'Description of pub.dev',
          createdAt: now,
          updatedAt: now,
          isFavorite: false,
        ),
        flutterFolder,
        const <Tag>[],
      ),
      (
        Url(
          url: 'https://pub.dev/packages/floor',
          title: 'Floor',
          metaImageUrl: 'https://pub.dev/packages/floor/og.png',
          metaDescription: 'Description of Floor',
          createdAt: now,
          updatedAt: now,
          isFavorite: false,
        ),
        dbFolder,
        const <Tag>[],
      ),
      (
        Url(
          url: 'https://sqlite.org',
          title: 'SQLite',
          metaImageUrl: 'https://sqlite.org/og.png',
          metaDescription: 'Description of SQLite',
          createdAt: now,
          updatedAt: now,
          isFavorite: false,
        ),
        dbFolder,
        const <Tag>[],
      ),
    ];

    await urlStore.clearAllAndCreateUrlFromRecords(records);
  }

  /// Prints current database contents to the debug console.
  static Future<void> printDatabase(UrlStore urlStore) async {
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
        'isFavorite=${u.isFavorite}, createdAt=${u.createdAt}',
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
  }
}
