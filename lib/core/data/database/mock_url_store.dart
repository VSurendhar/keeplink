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
import 'package:keep_links/core/data/database/exception/url_not_found_exception.dart';
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

  List<Folder> get _untrashedFolders =>
      List.unmodifiable(_folders.where((folder) => !folder.trash));

  void _notifyFolders() => _folderStreamController.add(_untrashedFolders);

  List<Url> get _untrashedUrls =>
      List.unmodifiable(_urls.where((url) => !url.trash));

  List<Url> get _trashedUrls {
    final urls = _urls.where((url) => url.trash).toList()
      ..sort((a, b) {
        final byUpdatedAt = b.updatedAt.compareTo(a.updatedAt);
        if (byUpdatedAt != 0) return byUpdatedAt;
        return (b.id ?? 0).compareTo(a.id ?? 0);
      });
    return List.unmodifiable(urls);
  }

  void _notifyUrls() => _urlStreamController.add(_untrashedUrls);

  List<Tag> get _untrashedTags =>
      List.unmodifiable(_tags.where((tag) => !tag.trash));

  void _notifyTags() => _tagStreamController.add(_untrashedTags);

  void _notifyUrlTags() =>
      _urlTagStreamController.add(List.unmodifiable(_urlTags));

  // Insert Operations
  @override
  Future<int> insertFolder(Folder folder) async {
    final trashedIndex = _folders.indexWhere(
      (item) => item.trash && item.folderName == folder.folderName,
    );
    final trashedId = trashedIndex == -1 ? null : _folders[trashedIndex].id;
    if (trashedId != null) {
      _folders[trashedIndex] = _folders[trashedIndex].copyWith(trash: false);
      _notifyFolders();
      return trashedId;
    }

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
    final newFolder = folder.copyWith(id: id);
    _folders.add(newFolder);
    _notifyFolders();
    return id;
  }

  @override
  Future<int> insertTag(Tag tag) async {
    final trashedIndex = _tags.indexWhere(
      (item) => item.trash && item.tagName == tag.tagName,
    );
    final trashedId = trashedIndex == -1 ? null : _tags[trashedIndex].id;
    if (trashedId != null) {
      _tags[trashedIndex] = _tags[trashedIndex].copyWith(trash: false);
      _notifyTags();
      return trashedId;
    }

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
    final newTag = tag.copyWith(id: id);
    _tags.add(newTag);
    _notifyTags();
    return id;
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
    yield _untrashedFolders;
    yield* _folderStreamController.stream;
  }

  @override
  Stream<List<Url>> findAllUrl() async* {
    yield _untrashedUrls;
    yield* _urlStreamController.stream;
  }

  @override
  Stream<List<Url>> findTrashedUrls() async* {
    yield _trashedUrls;
    yield* _urlStreamController.stream.map((_) => _trashedUrls);
  }

  @override
  Future<List<Folder>> findFoldersOfTrashedUrls() async {
    final folderIds = _trashedUrls.map((url) => url.folderId).toSet();
    return _folders.where((folder) => folderIds.contains(folder.id)).toList();
  }

  @override
  Future<List<Tag>> findTagsOfTrashedUrls() async {
    final urlTags = await findUrlTagsOfTrashedUrls();
    final tagIds = urlTags.map((urlTag) => urlTag.tagId).toSet();
    return _tags.where((tag) => tagIds.contains(tag.id)).toList();
  }

  @override
  Future<List<UrlTag>> findUrlTagsOfTrashedUrls() async {
    final urlIds = _trashedUrls.map((url) => url.id).toSet();
    return _urlTags.where((urlTag) => urlIds.contains(urlTag.urlId)).toList();
  }

  @override
  Stream<List<Tag>> findAllTags() async* {
    yield _untrashedTags;
    yield* _tagStreamController.stream;
  }

  @override
  Stream<List<UrlTag>> findAllUrlTags() async* {
    yield List.unmodifiable(_urlTags);
    yield* _urlTagStreamController.stream;
  }

  @override
  Future<Map<int, int>> findUrlCountPerFolder() async =>
      UrlStore.countById(_untrashedUrls.map((url) => url.folderId));

  @override
  Future<Map<int, int>> findUrlCountPerTag() async {
    final untrashedUrlIds = _untrashedUrls.map((url) => url.id).toSet();
    return UrlStore.countById(
      _urlTags
          .where((urlTag) => untrashedUrlIds.contains(urlTag.urlId))
          .map((urlTag) => urlTag.tagId),
    );
  }

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
      if (!folder.trash && folder.folderName == folderName) return folder;
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
      if (!item.trash && item.url == url) return item;
    }
    return null;
  }

  @override
  Future<Url?> findUrlByTitle(String title) async {
    for (final item in _urls) {
      if (!item.trash && item.title == title) return item;
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
      if (!tag.trash && tag.tagName == tagName) return tag;
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
  Future<int> createUrl({required Url url, List<int> tagIds = const []}) async {
    // Validate everything before inserting, so nothing is saved on failure.
    await _checkIfUrlExists(url);
    await _checkIfFolderExists(url.folderId, allowTrashed: url.trash);
    // A Set links a tag listed twice only once.
    final uniqueTagIds = tagIds.toSet();
    await _checkIfTagsExist(uniqueTagIds, allowTrashed: url.trash);

    final urlId = url.id ?? _urlIdSeq++;
    _urls.add(url.copyWith(id: urlId));
    for (final tagId in uniqueTagIds) {
      _urlTags.add(UrlTag(urlId: urlId, tagId: tagId));
    }
    _notifyUrlTags();
    // After the tags are linked, so listeners see the URL with its tags.
    _notifyUrls();
    return urlId;
  }

  @override
  Future<void> moveUrlToTrash(int urlId) async {
    final url = await findUrlById(urlId);
    if (url == null || url.trash) {
      throw UrlNotFoundException(urlId);
    }

    _urls[_urls.indexOf(url)] = url.copyWith(
      trash: true,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    _notifyUrls();
  }

  @override
  Future<void> restoreUrl(int urlId) async {
    // Validate everything before updating, so nothing changes on failure.
    final url = await findUrlById(urlId);
    if (url == null || !url.trash) {
      throw UrlNotFoundException(urlId);
    }
    await _checkIfSavedUrlExists(url);
    await _checkIfFolderExists(url.folderId, allowTrashed: true);
    final tagIds = _urlTags
        .where((urlTag) => urlTag.urlId == urlId)
        .map((urlTag) => urlTag.tagId)
        .toSet();
    await _checkIfTagsExist(tagIds, allowTrashed: true);

    for (var i = 0; i < _folders.length; i++) {
      final folder = _folders[i];
      if (folder.id == url.folderId && folder.trash) {
        _folders[i] = folder.copyWith(trash: false);
      }
    }
    for (var i = 0; i < _tags.length; i++) {
      final tag = _tags[i];
      if (tagIds.contains(tag.id) && tag.trash) {
        _tags[i] = tag.copyWith(trash: false);
      }
    }
    _urls[_urls.indexOf(url)] = url.copyWith(
      trash: false,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    _notifyFolders();
    _notifyTags();
    _notifyUrls();
  }

  @override
  Future<void> emptyTrash() async {
    final trashedUrlIds = _trashedUrls.map((url) => url.id).toSet();
    _urlTags.removeWhere((urlTag) => trashedUrlIds.contains(urlTag.urlId));
    _urls.removeWhere((url) => url.trash);

    // Only trashed folders and tags that no URL uses are deleted.
    final usedFolderIds = _urls.map((url) => url.folderId).toSet();
    _folders.removeWhere(
      (folder) => folder.trash && !usedFolderIds.contains(folder.id),
    );
    final usedTagIds = _urlTags.map((urlTag) => urlTag.tagId).toSet();
    _tags.removeWhere((tag) => tag.trash && !usedTagIds.contains(tag.id));
    _notifyUrlTags();
    _notifyUrls();
    _notifyFolders();
    _notifyTags();
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
    final folder = await findFolderById(sourceFolderId);
    if (folder == null) {
      throw FolderNotFoundException(sourceFolderId);
    }
    if (AppDefaults.isDefaultFolder(folder)) {
      throw ArgumentError('Cannot delete the default folder');
    }

    for (var i = 0; i < _urls.length; i++) {
      final url = _urls[i];
      if (url.folderId == sourceFolderId && !url.trash) {
        _urls[i] = url.copyWith(folderId: targetFolderId);
      }
    }
    // Trashed URLs stay in the folder, so it's kept for restoring them.
    if (_urls.any((url) => url.folderId == sourceFolderId)) {
      _folders[_folders.indexOf(folder)] = folder.copyWith(trash: true);
    } else {
      _folders.remove(folder);
    }
    _notifyUrls();
    _notifyFolders();
  }

  @override
  Future<void> deleteTagAndUrlTags(int tagId) async {
    final tag = await findTagById(tagId);
    if (tag == null) {
      throw TagNotFoundException(tagId);
    }
    if (AppDefaults.isDefaultTag(tag)) {
      throw ArgumentError('Cannot delete the default tag');
    }

    final trashedUrlIds = _urls
        .where((url) => url.trash)
        .map((url) => url.id)
        .toSet();
    _urlTags.removeWhere(
      (urlTag) =>
          urlTag.tagId == tagId && !trashedUrlIds.contains(urlTag.urlId),
    );
    // Trashed URLs keep their tag links, so the tag is kept for restoring them.
    if (_urlTags.any((urlTag) => urlTag.tagId == tagId)) {
      _tags[_tags.indexOf(tag)] = tag.copyWith(trash: true);
    } else {
      _tags.remove(tag);
    }
    _notifyUrlTags();
    _notifyTags();
  }

  /// Throws [DuplicateUrlException] if any URL has the same id or a saved URL
  /// has the same address, or [DuplicateTitleException] if a saved URL has the
  /// same title.
  ///
  /// A trashed [url] may share its address and title with any other URL, so
  /// only its id is checked.
  Future<void> _checkIfUrlExists(Url url) async {
    final id = url.id;
    final idTaken = id != null && await findUrlById(id) != null;
    if (idTaken) {
      throw DuplicateUrlException(url.url);
    }
    if (url.trash) return;

    await _checkIfSavedUrlExists(url);
  }

  /// Throws [DuplicateUrlException] if a saved URL has the same address as
  /// [url], or [DuplicateTitleException] if a saved URL has the same title.
  Future<void> _checkIfSavedUrlExists(Url url) async {
    if (await findUrlByUrlString(url.url) != null) {
      throw DuplicateUrlException(url.url);
    }
    if (await findUrlByTitle(url.title) != null) {
      throw DuplicateTitleException(url.title);
    }
  }

  /// Throws [FolderNotFoundException] if no folder has [folderId], or if it is
  /// trashed and not [allowTrashed].
  Future<void> _checkIfFolderExists(
    int folderId, {
    bool allowTrashed = false,
  }) async {
    final folder = await findFolderById(folderId);
    if (folder == null || (folder.trash && !allowTrashed)) {
      throw FolderNotFoundException(folderId);
    }
  }

  /// Throws [TagNotFoundException] for the first id in [tagIds] with no tag, or
  /// whose tag is trashed and not [allowTrashed].
  Future<void> _checkIfTagsExist(
    Iterable<int> tagIds, {
    bool allowTrashed = false,
  }) async {
    for (final tagId in tagIds) {
      final tag = await findTagById(tagId);
      if (tag == null || (tag.trash && !allowTrashed)) {
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
