import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:mindful_links/core/data/database/entity/folder.dart';
import 'package:mindful_links/core/data/database/entity/tag.dart';
import 'package:mindful_links/core/data/database/entity/url.dart';
import 'package:mindful_links/core/data/database/url_store.dart';
import 'package:mindful_links/core/app_defaults.dart';
import 'package:mindful_links/features/settings/service/app_settings_service.dart';

/// Developer-only data operations.
@lazySingleton
class DeveloperOptionsService {
  DeveloperOptionsService(this._appSettingsService);

  final AppSettingsService _appSettingsService;

  /// Sets default app theme, language, and retention period.
  Future<void> initialAppSettings() async {
    await _appSettingsService.saveAppTheme(AppDefaults.appTheme);
    await _appSettingsService.saveLanguage(AppDefaults.appLanguage);
    await _appSettingsService.saveTrashRetention(AppDefaults.trashRetention);
  }

  /// Populates the URL store with initial development records.
  Future<void> seedDatabase(UrlStore urlStore) async {
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
    await urlStore.seedDefaultFolderIfNotExist();
    await urlStore.seedDefaultTagsIfNotExist();
  }

  /// Prints current database contents to the debug console.
  Future<void> printDatabase(UrlStore urlStore) async {
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
