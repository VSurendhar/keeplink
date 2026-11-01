import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:mindful_links/core/data/database/url_store.dart';
import 'package:mindful_links/core/data/hive/models/app_settings.dart';
import 'package:mindful_links/features/logger/logger.dart';
import 'package:mindful_links/utils/utils.dart';

import 'app/app.dart';
import 'app/app_bloc_observer.dart';
import 'bootstrap.dart';
import 'core/build_config.dart';
import 'core/data/database/entity/folder.dart';
import 'core/data/database/entity/tag.dart';
import 'core/data/database/entity/url.dart';
import 'features/settings/service/app_settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BuildConfig.isDevelopmentBuild = true;

  Bloc.observer = const AppBlocObserver();

  await bootstrap();
  // await initialDatabaseSetup();
  // await initialAppSettings();

  runApp(App());
}

Future<void> initialDatabaseSetup() async {
  final urlStore = GetIt.instance.get<UrlStore>();

  try {
    await _seedDatabase(urlStore);
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
    await _printDatabase(urlStore);
  }
}

Future<void> initialAppSettings() async {
  AppSettingsService settingsService = GetIt.instance.get<AppSettingsService>();
  settingsService.saveAppTheme(AppTheme.light);
  settingsService.saveLanguage(AppLanguage.englishUs);
  settingsService.saveTrashRetention(30);
}

/*
 * DATABASE SEED DATA TABLES:
 *
 * 📁 FOLDERS TABLE (`folder`)
 * ┌────┬────────────────────┐
 * │ ID │ Folder Name        │
 * ├────┼────────────────────┤
 * │ 1  │ Flutter Resources  │
 * │ 2  │ Database Resources │
 * └────┴────────────────────┘
 *
 * 🔗 URLS TABLE (`url`)
 * ┌────┬───────────┬────────────────────────────────┬───────────┬────────────────────┐
 * │ ID │ Title     │ URL                            │ Folder ID │ Folder Name        │
 * ├────┼───────────┼────────────────────────────────┼───────────┼────────────────────┤
 * │ 1  │ Flutter   │ https://flutter.dev            │     1     │ Flutter Resources  │
 * │ 2  │ Dart      │ https://dart.dev               │     1     │ Flutter Resources  │
 * │ 3  │ pub.dev   │ https://pub.dev                │     1     │ Flutter Resources  │
 * │ 4  │ Floor     │ https://pub.dev/packages/floor │     2     │ Database Resources │
 * │ 5  │ SQLite    │ https://sqlite.org             │     2     │ Database Resources │
 * └────┴───────────┴────────────────────────────────┴───────────┴────────────────────┘
 *
 * 🏷️ TAGS TABLE (`tag`)
 * ┌────┬───────────┐
 * │ ID │ Tag Name  │
 * ├────┼───────────┤
 * │ 1  │ flutter   │
 * │ 2  │ dart      │
 * │ 3  │ mobile    │
 * │ 4  │ database  │
 * │ 5  │ tutorial  │
 * └────┴───────────┘
 *
 * 🔗🏷️ URL_TAG TABLE (`url_tag`)
 * ┌────────┬────────┬───────────┐
 * │ URL ID │ Tag ID │ Tag Name  │
 * ├────────┼────────┼───────────┤
 * │   1    │   1    │ flutter   │
 * │   1    │   2    │ dart      │
 * │   1    │   3    │ mobile    │
 * │   2    │   3    │ mobile    │
 * │   2    │   4    │ database  │
 * │   2    │   5    │ tutorial  │
 * └────────┴────────┴───────────┘
 */
Future<void> _seedDatabase(UrlStore urlStore) async {
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

Future<void> _printDatabase(UrlStore urlStore) async {
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
    final folder = u.id != null
        ? await urlStore.findFolderForUrlId(u.id!)
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
