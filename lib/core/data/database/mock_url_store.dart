import 'dart:async';
import 'package:mindful_links/core/app_defaults.dart';
import 'package:mindful_links/core/data/database/entity/folder.dart';
import 'package:mindful_links/core/data/database/entity/tag.dart';
import 'package:mindful_links/core/data/database/entity/url.dart';
import 'package:mindful_links/core/data/database/entity/url_tag.dart';
import 'package:mindful_links/core/data/database/exception/duplicate_url_exception.dart';
import 'package:mindful_links/core/data/database/url_store.dart';

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
    final existingId = folder.id;
    final int id = existingId ?? _folderIdSeq++;
    final newFolder = Folder(id: id, folderName: folder.folderName);
    _folders.add(newFolder);
    _notifyFolders();
    return id;
  }

  @override
  Future<int> insertUrl(Url url) async {
    final existingId = url.id;
    final int id = existingId ?? _urlIdSeq++;
    final newUrl = url.copyWith(id: id);
    _urls.add(newUrl);
    _notifyUrls();
    return id;
  }

  @override
  Future<int> insertTag(Tag tag) async {
    final existingId = tag.id;
    final int id = existingId ?? _tagIdSeq++;
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
    final folderId = matchedUrl.folderId;
    if (folderId == null) return null;
    return findFolderById(folderId);
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
      UrlStore.countById(_urls.map((url) => url.folderId).nonNulls);

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
    final lowerName = folderName.toLowerCase();
    for (final folder in _folders) {
      if (folder.folderName.toLowerCase() == lowerName) return folder;
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
  Future<Tag?> findTagById(int id) async {
    for (final tag in _tags) {
      if (tag.id == id) return tag;
    }
    return null;
  }

  @override
  Future<Tag?> findTagByName(String tagName) async {
    final lowerName = tagName.toLowerCase();
    for (final tag in _tags) {
      if (tag.tagName.toLowerCase() == lowerName) return tag;
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
    required Folder folder,
    List<Tag> tags = const [],
  }) async {
    final existingUrl = await findUrlByUrlString(url.url);
    if (existingUrl != null) {
      throw DuplicateUrlException(url.url);
    }

    final int folderId;
    final fId = folder.id;
    if (fId != null) {
      folderId = fId;
    } else {
      final existingFolder = await findFolderByName(folder.folderName);
      final existingFolderId = existingFolder?.id;
      if (existingFolderId != null) {
        folderId = existingFolderId;
      } else {
        folderId = await insertFolder(folder);
      }
    }

    final urlId = await insertUrl(url.copyWith(folderId: folderId));

    for (final tag in tags) {
      final int tagId;
      final tId = tag.id;
      if (tId != null) {
        tagId = tId;
      } else {
        final existingTag = await findTagByName(tag.tagName);
        final existingTagId = existingTag?.id;
        if (existingTagId != null) {
          tagId = existingTagId;
        } else {
          tagId = await insertTag(tag);
        }
      }

      final existingUrlTag = await findUrlTag(urlId, tagId);
      if (existingUrlTag == null) {
        await insertUrlTag(UrlTag(urlId: urlId, tagId: tagId));
      }
    }

    return urlId;
  }

  @override
  Future<List<int>> clearAllAndCreateUrlFromRecords(
    List<UrlRecord> records,
  ) async {
    await clearAll();
    final ids = <int>[];
    for (final record in records) {
      final (url, folder, tags) = record;
      final id = await createUrl(url: url, folder: folder, tags: tags);
      ids.add(id);
    }
    return ids;
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
