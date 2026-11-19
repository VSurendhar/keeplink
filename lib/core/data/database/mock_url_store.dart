import 'dart:async';
import 'package:keep_links/core/utils/app_defaults.dart';
import 'package:keep_links/core/data/database/entity/folder.dart';
import 'package:keep_links/core/data/database/entity/tag.dart';
import 'package:keep_links/core/data/database/entity/url.dart';
import 'package:keep_links/core/data/database/entity/url_tag.dart';
import 'package:keep_links/core/data/database/exception/duplicate_title_exception.dart';
import 'package:keep_links/core/data/database/exception/duplicate_url_exception.dart';
import 'package:keep_links/core/data/database/exception/folder_not_found_exception.dart';
import 'package:keep_links/core/data/database/exception/tag_not_found_exception.dart';
import 'package:keep_links/core/data/database/url_store.dart';

class MockUrlStore implements UrlStore {
  MockUrlStore() {
    _initDefaults();
  }

  final List<Folder> _folders = [];
  final List<Url> _urls = [];
  final List<Tag> _tags = [];
  final List<UrlTag> _urlTags = [];

  final StreamController<List<Folder>> _folderStreamController =
      StreamController<List<Folder>>.broadcast();
  final StreamController<List<Url>> _urlStreamController =
      StreamController<List<Url>>.broadcast();
  final StreamController<List<Tag>> _tagStreamController =
      StreamController<List<Tag>>.broadcast();
  final StreamController<List<UrlTag>> _urlTagStreamController =
      StreamController<List<UrlTag>>.broadcast();

  int _folderIdSeq = 1;
  int _urlIdSeq = 1;
  int _tagIdSeq = 1;

  void _initDefaults() {
    for (final folder in AppDefaults.defaultFolders) {
      final exists = _folders.any((f) => f.folderName == folder.folderName);
      if (!exists) {
        final id = folder.id ?? _folderIdSeq++;
        _folders.add(Folder(id: id, folderName: folder.folderName));
      }
    }
    for (final tag in AppDefaults.defaultTags) {
      final exists = _tags.any((t) => t.tagName == tag.tagName);
      if (!exists) {
        final id = tag.id ?? _tagIdSeq++;
        _tags.add(Tag(id: id, tagName: tag.tagName));
      }
    }
  }

  void _notifyFolders() =>
      _folderStreamController.add(List.unmodifiable(_folders));

  void _notifyUrls() => _urlStreamController.add(List.unmodifiable(_urls));

  void _notifyTags() => _tagStreamController.add(List.unmodifiable(_tags));

  void _notifyUrlTags() =>
      _urlTagStreamController.add(List.unmodifiable(_urlTags));

  // Insert Operations
  @override
  Future<int> insertFolder(Folder folder) async {
    // Mirrors the database's unique constraint on `folder_name` and primary
    // key on `id`.
    if (await findFolderByName(folder.folderName) != null) {
      throw StateError('Folder "${folder.folderName}" already exists');
    }
    final existingId = folder.id;
    if (existingId != null && await findFolderById(existingId) != null) {
      throw StateError('Folder id $existingId already exists');
    }
    final int id = existingId ?? _folderIdSeq;
    // Like SQLite's autoincrement, the next generated id is above any used id.
    if (id >= _folderIdSeq) _folderIdSeq = id + 1;
    final newFolder = Folder(id: id, folderName: folder.folderName);
    _folders.add(newFolder);
    _notifyFolders();
    return id;
  }

  @override
  Future<int> insertTag(Tag tag) async {
    // Mirrors the database's unique constraint on `tag_name` and primary key
    // on `id`.
    if (await findTagByName(tag.tagName) != null) {
      throw StateError('Tag "${tag.tagName}" already exists');
    }
    final existingId = tag.id;
    if (existingId != null && await findTagById(existingId) != null) {
      throw StateError('Tag id $existingId already exists');
    }
    final int id = existingId ?? _tagIdSeq;
    // Like SQLite's autoincrement, the next generated id is above any used id.
    if (id >= _tagIdSeq) _tagIdSeq = id + 1;
    final newTag = Tag(id: id, tagName: tag.tagName);
    _tags.add(newTag);
    _notifyTags();
    return id;
  }

  @override
  Future<void> insertUrlTag(UrlTag urlTag) async {
    _urlTags.add(urlTag);
    _notifyUrlTags();
  }

  // Query Operations
  @override
  Future<Folder?> findFolderForUrlId(int id) async {
    Url? matchedUrl;
    for (final item in _urls) {
      if (item.id == id) {
        matchedUrl = item;
        break;
      }
    }
    if (matchedUrl == null) return null;
    return findFolderById(matchedUrl.folderId);
  }

  @override
  Stream<List<Folder>> findAllFolders() async* {
    yield List.unmodifiable(_folders);
    yield* _folderStreamController.stream;
  }

  @override
  Stream<List<Url>> findAllUrl() async* {
    yield List.unmodifiable(_urls);
    yield* _urlStreamController.stream;
  }

  @override
  Stream<List<Tag>> findAllTags() async* {
    yield List.unmodifiable(_tags);
    yield* _tagStreamController.stream;
  }

  @override
  Stream<List<UrlTag>> findAllUrlTags() async* {
    yield List.unmodifiable(_urlTags);
    yield* _urlTagStreamController.stream;
  }

  @override
  Future<Map<int, int>> findUrlCountPerFolder() async =>
      UrlStore.countById(_urls.map((url) => url.folderId));

  @override
  Future<Map<int, int>> findUrlCountPerTag() async =>
      UrlStore.countById(_urlTags.map((urlTag) => urlTag.tagId));

  @override
  Future<Folder?> findFolderById(int id) async {
    for (final folder in _folders) {
      if (folder.id == id) return folder;
    }
    return null;
  }

  @override
  Future<Folder?> findFolderByName(String folderName) async {
    for (final folder in _folders) {
      if (folder.folderName == folderName) return folder;
    }
    return null;
  }

  @override
  Future<Url?> findUrlById(int id) async {
    for (final url in _urls) {
      if (url.id == id) return url;
    }
    return null;
  }

  @override
  Future<Url?> findUrlByUrlString(String url) async {
    for (final item in _urls) {
      if (item.url == url) return item;
    }
    return null;
  }

  @override
  Future<Url?> findUrlByTitle(String title) async {
    for (final item in _urls) {
      if (item.title == title) return item;
    }
    return null;
  }

  @override
  Future<Tag?> findTagById(int id) async {
    for (final tag in _tags) {
      if (tag.id == id) return tag;
    }
    return null;
  }

  @override
  Future<Tag?> findTagByName(String tagName) async {
    for (final tag in _tags) {
      if (tag.tagName == tagName) return tag;
    }
    return null;
  }

  @override
  Future<UrlTag?> findUrlTag(int urlId, int tagId) async {
    for (final urlTag in _urlTags) {
      if (urlTag.urlId == urlId && urlTag.tagId == tagId) return urlTag;
    }
    return null;
  }

  @override
  Future<void> clearAll() async {
    _folders.clear();
    _urls.clear();
    _tags.clear();
    _urlTags.clear();
    _notifyFolders();
    _notifyUrls();
    _notifyTags();
    _notifyUrlTags();
  }

  @override
  Future<int> createUrl({
    required Url url,
    List<int> tagIds = const [],
  }) async {
    // Validate everything before inserting, so nothing is saved on failure.
    await _checkIfUrlExists(url);
    await _checkIfFolderExists(url.folderId);
    // A Set links a tag listed twice only once.
    final uniqueTagIds = tagIds.toSet();
    await _checkIfTagsExist(uniqueTagIds);

    final urlId = url.id ?? _urlIdSeq++;
    _urls.add(url.copyWith(id: urlId));
    _notifyUrls();
    for (final tagId in uniqueTagIds) {
      await insertUrlTag(UrlTag(urlId: urlId, tagId: tagId));
    }
    return urlId;
  }

  @override
  Future<void> deleteFolderAndMoveUrls({
    required int sourceFolderId,
    required int targetFolderId,
  }) async {
    if (sourceFolderId == targetFolderId) {
      throw ArgumentError('Cannot move URLs into the folder being deleted');
    }
    await _checkIfFolderExists(targetFolderId);
    await _checkIfFolderExists(sourceFolderId);

    for (var i = 0; i < _urls.length; i++) {
      final url = _urls[i];
      if (url.folderId == sourceFolderId) {
        _urls[i] = url.copyWith(folderId: targetFolderId);
      }
    }
    _folders.removeWhere((folder) => folder.id == sourceFolderId);
    _notifyUrls();
    _notifyFolders();
  }

  @override
  Future<void> deleteTagAndUrlTags(int tagId) async {
    await _checkIfTagsExist([tagId]);

    _urlTags.removeWhere((urlTag) => urlTag.tagId == tagId);
    _tags.removeWhere((tag) => tag.id == tagId);
    _notifyUrlTags();
    _notifyTags();
  }

  /// Throws [DuplicateUrlException] if a URL with the same id or address
  /// exists, or [DuplicateTitleException] if one with the same title exists.
  Future<void> _checkIfUrlExists(Url url) async {
    final id = url.id;
    final idTaken = id != null && await findUrlById(id) != null;
    if (idTaken || await findUrlByUrlString(url.url) != null) {
      throw DuplicateUrlException(url.url);
    }
    if (await findUrlByTitle(url.title) != null) {
      throw DuplicateTitleException(url.title);
    }
  }

  /// Throws [FolderNotFoundException] if no folder has [folderId].
  Future<void> _checkIfFolderExists(int folderId) async {
    if (await findFolderById(folderId) == null) {
      throw FolderNotFoundException(folderId);
    }
  }

  /// Throws [TagNotFoundException] for the first id in [tagIds] with no tag.
  Future<void> _checkIfTagsExist(Iterable<int> tagIds) async {
    for (final tagId in tagIds) {
      if (await findTagById(tagId) == null) {
        throw TagNotFoundException(tagId);
      }
    }
  }

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
