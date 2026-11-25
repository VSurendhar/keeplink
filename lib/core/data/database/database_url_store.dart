import 'package:keep_links/core/utils/app_defaults.dart';
import 'package:keep_links/core/data/database/dao/url_dao.dart';
import 'package:keep_links/core/data/database/entity/folder.dart';
import 'package:keep_links/core/data/database/entity/tag.dart';
import 'package:keep_links/core/data/database/entity/url.dart';
import 'package:keep_links/core/data/database/entity/url_tag.dart';
import 'package:keep_links/core/data/database/url_database.dart';
import 'package:keep_links/core/data/database/url_store.dart';

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
          .databaseBuilder('keep_links_db.db')
          .addCallback(urlDatabaseCallback)
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
      (await _dao).createFolder(folder);

  @override
  Future<int> insertTag(Tag tag) async => (await _dao).createTag(tag);

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
  Stream<List<Url>> findTrashedUrls() async* {
    final dao = await _dao;
    yield* dao.findTrashedUrls();
  }

  @override
  Future<List<Folder>> findFoldersOfTrashedUrls() async =>
      (await _dao).findFoldersOfTrashedUrls();

  @override
  Future<List<Tag>> findTagsOfTrashedUrls() async =>
      (await _dao).findTagsOfTrashedUrls();

  @override
  Future<List<UrlTag>> findUrlTagsOfTrashedUrls() async =>
      (await _dao).findUrlTagsOfTrashedUrls();

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
      UrlStore.countById(await (await _dao).findAllUrlFolderIds());

  @override
  Future<Map<int, int>> findUrlCountPerTag() async =>
      UrlStore.countById(await (await _dao).findAllUrlTagIds());

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
  Future<Url?> findUrlByTitle(String title) async =>
      (await _dao).findUrlByTitle(title);

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
    List<int> tagIds = const [],
  }) async => (await _dao).createUrl(url, tagIds);

  @override
  Future<void> restoreUrl(int urlId) async => (await _dao).restoreUrl(urlId);

  @override
  Future<void> deleteFolderAndMoveUrls({
    required int sourceFolderId,
    required int targetFolderId,
  }) async =>
      (await _dao).deleteFolderAndMoveUrls(sourceFolderId, targetFolderId);

  @override
  Future<void> deleteTagAndUrlTags(int tagId) async =>
      (await _dao).deleteTagAndUrlTags(tagId);

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
