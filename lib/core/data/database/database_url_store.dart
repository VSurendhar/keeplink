import 'package:mindful_links/core/app_defaults.dart';
import 'package:mindful_links/core/data/database/dao/url_dao.dart';
import 'package:mindful_links/core/data/database/entity/folder.dart';
import 'package:mindful_links/core/data/database/entity/tag.dart';
import 'package:mindful_links/core/data/database/entity/url.dart';
import 'package:mindful_links/core/data/database/entity/url_tag.dart';
import 'package:mindful_links/core/data/database/url_database.dart';
import 'package:mindful_links/core/data/database/url_store.dart';

class DatabaseUrlStore implements UrlStore {
  DatabaseUrlStore() {
    _init();
  }

  Future<UrlDatabase>? _dbFuture;

  void _init() {
    getDatabase();
  }

  Future<UrlDatabase> getDatabase() {
    return _dbFuture ??= _buildDatabase();
  }

  Future<UrlDatabase> _buildDatabase() async {
    try {
      return await $FloorUrlDatabase
          .databaseBuilder('mindful_links_db.db')
          .build();
    } catch (_) {
      _dbFuture = null;
      rethrow;
    }
  }

  Future<UrlDao> get _dao async {
    final db = await getDatabase();
    return db.urlDao;
  }

  // Insert Operations
  @override
  Future<int> insertFolder(Folder folder) async =>
      (await _dao).insertFolder(folder);

  @override
  Future<int> insertUrl(Url url) async => (await _dao).insertUrl(url);

  @override
  Future<int> insertTag(Tag tag) async => (await _dao).insertTag(tag);

  @override
  Future<void> insertUrlTag(UrlTag urlTag) async =>
      (await _dao).insertUrlTag(urlTag);

  // Query Operations
  @override
  Future<Folder?> findFolderForUrlId(int id) async =>
      (await _dao).findFolderForUrlId(id);

  @override
  Stream<List<Folder>> findAllFolders() async* {
    final dao = await _dao;
    yield* dao.findAllFolders();
  }

  @override
  Stream<List<Url>> findAllUrl() async* {
    final dao = await _dao;
    yield* dao.findAllUrl();
  }

  @override
  Stream<List<Tag>> findAllTags() async* {
    final dao = await _dao;
    yield* dao.findAllTags();
  }

  @override
  Stream<List<UrlTag>> findAllUrlTags() async* {
    final dao = await _dao;
    yield* dao.findAllUrlTags();
  }

  @override
  Future<Map<int, int>> findUrlCountPerFolder() async =>
      UrlStore.countUrlsPerFolder(await (await _dao).findAllUrlFolderIds());

  @override
  Future<Folder?> findFolderById(int id) async =>
      (await _dao).findFolderById(id);

  @override
  Future<Folder?> findFolderByName(String folderName) async =>
      (await _dao).findFolderByName(folderName);

  @override
  Future<Url?> findUrlById(int id) async => (await _dao).findUrlById(id);

  @override
  Future<Url?> findUrlByUrlString(String url) async =>
      (await _dao).findUrlByUrlString(url);

  @override
  Future<Tag?> findTagById(int id) async => (await _dao).findTagById(id);

  @override
  Future<Tag?> findTagByName(String tagName) async =>
      (await _dao).findTagByName(tagName);

  @override
  Future<UrlTag?> findUrlTag(int urlId, int tagId) async =>
      (await _dao).findUrlTag(urlId, tagId);

  @override
  Future<void> clearAll() async => (await _dao).clearAll();

  @override
  Future<int> createUrl({
    required Url url,
    required Folder folder,
    List<Tag> tags = const [],
  }) async => (await _dao).createUrl(url, folder, tags);

  @override
  Future<List<int>> clearAllAndCreateUrlFromRecords(
    List<UrlRecord> records,
  ) async => (await _dao).clearAllAndCreateUrlFromRecords(records);

  @override
  Future<void> seedDefaultFolderIfNotExist() async {
    for (final folder in AppDefaults.defaultFolders) {
      final existing = await findFolderByName(folder.folderName);
      if (existing == null) {
        await insertFolder(folder);
      }
    }
  }

  @override
  Future<void> seedDefaultTagsIfNotExist() async {
    for (final tag in AppDefaults.defaultTags) {
      final existing = await findTagByName(tag.tagName);
      if (existing == null) {
        await insertTag(tag);
      }
    }
  }
}
