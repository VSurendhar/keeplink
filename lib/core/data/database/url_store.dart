import 'package:injectable/injectable.dart';
import 'package:mindful_links/core/data/database/database_url_store.dart';
import 'package:mindful_links/core/data/database/entity/folder.dart';
import 'package:mindful_links/core/data/database/entity/tag.dart';
import 'package:mindful_links/core/data/database/entity/url.dart';
import 'package:mindful_links/core/data/database/entity/url_tag.dart';

export 'package:mindful_links/core/data/database/database_url_store.dart';
export 'package:mindful_links/core/data/database/mock_url_store.dart';
export 'package:mindful_links/core/data/database/url_store_switcher.dart';

@lazySingleton
abstract class UrlStore {
  @factoryMethod
  factory UrlStore() => DatabaseUrlStore();

  // Insert Operations
  Future<int> insertFolder(Folder folder);
  Future<int> insertUrl(Url url);
  Future<int> insertTag(Tag tag);
  Future<void> insertUrlTag(UrlTag urlTag);

  // Query Operations
  Future<Folder?> findFolderForUrlId(int id);
  Stream<List<Folder>> findAllFolders();
  Stream<List<Url>> findAllUrl();
  Stream<List<Tag>> findAllTags();
  Stream<List<UrlTag>> findAllUrlTags();

  Future<Folder?> findFolderById(int id);
  Future<Folder?> findFolderByName(String folderName);
  Future<Url?> findUrlById(int id);
  Future<Url?> findUrlByUrlString(String url);
  Future<Tag?> findTagById(int id);
  Future<Tag?> findTagByName(String tagName);
  Future<UrlTag?> findUrlTag(int urlId, int tagId);

  /// Number of URLs in each folder, keyed by folder id.
  ///
  /// Folders with no URLs are not in the map; read them as `counts[id] ?? 0`.
  Future<Map<int, int>> findUrlCountPerFolder();

  /// Number of URLs with each tag, keyed by tag id.
  ///
  /// Tags with no URLs are not in the map; read them as `counts[id] ?? 0`.
  Future<Map<int, int>> findUrlCountPerTag();

  Future<void> clearAll();
  Future<int> createUrl({
    required Url url,
    required Folder folder,
    List<Tag> tags = const [],
  });
  Future<List<int>> clearAllAndCreateUrlFromRecords(List<UrlRecord> records);

  Future<void> seedDefaultFolderIfNotExist();
  Future<void> seedDefaultTagsIfNotExist();

  /// Counts how many times each id appears in [ids], e.g. `[1, 1, 4]` gives
  /// `{1: 2, 4: 1}`. Used for URL counts per folder and per tag.
  static Map<int, int> countById(Iterable<int> ids) {
    final counts = <int, int>{};
    for (final id in ids) {
      counts[id] = (counts[id] ?? 0) + 1;
    }
    return counts;
  }
}

typedef UrlRecord = (Url url, Folder folder, List<Tag> tags);
