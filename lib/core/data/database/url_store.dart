import 'package:injectable/injectable.dart';
import 'package:mindful_links/core/data/database/dao/url_dao.dart';
import 'package:mindful_links/core/data/database/entity/folder.dart';
import 'package:mindful_links/core/data/database/entity/tag.dart';
import 'package:mindful_links/core/data/database/entity/url.dart';
import 'package:mindful_links/core/data/database/entity/url_tag.dart';
import 'package:mindful_links/core/data/database/url_database.dart';

@singleton
class UrlStore {
  UrlStore() {
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
  Future<int> insertFolder(Folder folder) async =>
      (await _dao).insertFolder(folder);

  Future<int> insertUrl(Url url) async => (await _dao).insertUrl(url);

  Future<int> insertTag(Tag tag) async => (await _dao).insertTag(tag);

  Future<void> insertUrlTag(UrlTag urlTag) async =>
      (await _dao).insertUrlTag(urlTag);

  // Query Operations
  Future<Folder?> findFolderForUrlId(int id) async =>
      (await _dao).findFolderForUrlId(id);

  Stream<List<Folder>> findAllFolders() async* {
    final dao = await _dao;
    yield* dao.findAllFolders();
  }

  Stream<List<Url>> findAllUrl() async* {
    final dao = await _dao;
    yield* dao.findAllUrl();
  }

  Stream<List<Tag>> findAllTags() async* {
    final dao = await _dao;
    yield* dao.findAllTags();
  }

  Stream<List<UrlTag>> findAllUrlTags() async* {
    final dao = await _dao;
    yield* dao.findAllUrlTags();
  }

  Future<Folder?> findFolderById(int id) async =>
      (await _dao).findFolderById(id);

  Future<Folder?> findFolderByName(String folderName) async =>
      (await _dao).findFolderByName(folderName);

  Future<Url?> findUrlById(int id) async => (await _dao).findUrlById(id);

  Future<Url?> findUrlByUrlString(String url) async =>
      (await _dao).findUrlByUrlString(url);

  Future<Tag?> findTagById(int id) async => (await _dao).findTagById(id);

  Future<Tag?> findTagByName(String tagName) async =>
      (await _dao).findTagByName(tagName);

  Future<UrlTag?> findUrlTag(int urlId, int tagId) async =>
      (await _dao).findUrlTag(urlId, tagId);

  Future<void> clearAll() async => (await _dao).clearAll();

  Future<int> createUrl({
    required Url url,
    required Folder folder,
    List<Tag> tags = const [],
  }) async => (await _dao).createUrl(url, folder, tags);

  Future<List<int>> clearAllAndCreateUrlFromRecords(
    List<UrlRecord> records,
  ) async => (await _dao).clearAllAndCreateUrlFromRecords(records);
}

typedef UrlRecord = (Url url, Folder folder, List<Tag> tags);