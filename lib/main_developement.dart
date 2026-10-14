import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:mindful_links/core/data/database/url_store.dart';
import 'package:mindful_links/features/logger/logger.dart';

import 'app/app_bloc_observer.dart';
import 'bootstrap.dart';
import 'core/data/database/entity/folder.dart';
import 'core/data/database/entity/tag.dart';
import 'core/data/database/entity/url.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bootstrap();

  Bloc.observer = const AppBlocObserver();

  await initialDatabaseSetup();
  await initialLoggingSetup();
}

Future<void> initialLoggingSetup() async {
  await initLogger();
  // loggingDemo();
}

void loggingDemo() {
  logDebug("Logging for Debug");
  logInfo("Logging for Info");
  logInfo("Logging for Info", showToast: true);
  try {
    final value = int.parse("mindful_links_app");
  } catch (e, st) {
    logError('Unexpected error while parsing', e, stackTrace: st);
  }
}

Future<void> initialDatabaseSetup() async {
  final urlStore = GetIt.instance.get<UrlStore>();

  bool isSuccess = await _clearDatabase(urlStore);
  if (isSuccess) {
    await _seedDatabase(urlStore);
    await _printDatabase(urlStore);
  }
}

Future<bool> _clearDatabase(UrlStore urlStore) async {
  try {
    await urlStore.clearAll();
    return true;
  } catch (e) {
    return false;
  }
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

  await urlStore.createUrl(
    url: Url(
      url: 'https://flutter.dev',
      title: 'Flutter',
      metaImageUrl: 'https://flutter.dev/og.png',
      metaDescription: 'Description of Flutter',
      createdAt: now,
      updatedAt: now,
      isFavorite: false,
    ),
    folder: flutterFolder,
    tags: [
      Tag(tagName: 'flutter'),
      Tag(tagName: 'dart'),
      Tag(tagName: 'mobile'),
    ],
  );

  await urlStore.createUrl(
    url: Url(
      url: 'https://dart.dev',
      title: 'Dart',
      metaImageUrl: 'https://dart.dev/og.png',
      metaDescription: 'Description of Dart',
      createdAt: now,
      updatedAt: now,
      isFavorite: false,
    ),
    folder: flutterFolder,
    tags: [
      Tag(tagName: 'mobile'),
      Tag(tagName: 'database'),
      Tag(tagName: 'tutorial'),
    ],
  );

  await urlStore.createUrl(
    url: Url(
      url: 'https://pub.dev',
      title: 'pub.dev',
      metaImageUrl: 'https://pub.dev/og.png',
      metaDescription: 'Description of pub.dev',
      createdAt: now,
      updatedAt: now,
      isFavorite: false,
    ),
    folder: flutterFolder,
  );

  await urlStore.createUrl(
    url: Url(
      url: 'https://pub.dev/packages/floor',
      title: 'Floor',
      metaImageUrl: 'https://pub.dev/packages/floor/og.png',
      metaDescription: 'Description of Floor',
      createdAt: now,
      updatedAt: now,
      isFavorite: false,
    ),
    folder: dbFolder,
  );

  await urlStore.createUrl(
    url: Url(
      url: 'https://sqlite.org',
      title: 'SQLite',
      metaImageUrl: 'https://sqlite.org/og.png',
      metaDescription: 'Description of SQLite',
      createdAt: now,
      updatedAt: now,
      isFavorite: false,
    ),
    folder: dbFolder,
  );
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
