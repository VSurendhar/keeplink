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

  /// Inserts [folder] as it is and returns its id.
  ///
  /// Does not check for an existing folder with the same name, so callers
  /// must check first (e.g. with [findFolderByName]) to avoid duplicates.
  /// If [folder] has an `id` that is already taken, the database throws.
  Future<int> insertFolder(Folder folder);

  /// Inserts [url] as it is and returns its id.
  ///
  /// Does not check for duplicates or link a folder/tags; use [createUrl]
  /// for that.
  Future<int> insertUrl(Url url);

  /// Inserts [tag] as it is and returns its id.
  ///
  /// Does not check for an existing tag with the same name, so callers must
  /// check first (e.g. with [findTagByName]) to avoid duplicates.
  /// If [tag] has an `id` that is already taken, the database throws.
  Future<int> insertTag(Tag tag);

  /// Links a URL to a tag. Returns nothing.
  ///
  /// The database store throws if the same URL-tag link already exists (the
  /// mock store adds a duplicate); check with [findUrlTag] first.
  Future<void> insertUrlTag(UrlTag urlTag);

  // Query Operations

  /// Returns the folder of the URL with this [id].
  ///
  /// Returns `null` if the URL doesn't exist or has no folder.
  Future<Folder?> findFolderForUrlId(int id);

  /// Emits all folders now and again whenever the folder table changes.
  Stream<List<Folder>> findAllFolders();

  /// Emits all URLs now and again whenever the URL table changes.
  Stream<List<Url>> findAllUrl();

  /// Emits all tags now and again whenever the tag table changes.
  Stream<List<Tag>> findAllTags();

  /// Emits all URL-tag links now and again whenever they change.
  Stream<List<UrlTag>> findAllUrlTags();

  /// Returns the folder with this [id], or `null` if there is none.
  Future<Folder?> findFolderById(int id);

  /// Returns the folder named exactly [folderName], or `null` if there is
  /// none.
  ///
  /// Case-sensitive: folder names can be in any language, where case folding
  /// doesn't apply or behaves inconsistently.
  Future<Folder?> findFolderByName(String folderName);

  /// Returns the URL with this [id], or `null` if there is none.
  Future<Url?> findUrlById(int id);

  /// Returns the saved URL whose address is exactly [url], or `null` if there
  /// is none. Used for the duplicate check.
  Future<Url?> findUrlByUrlString(String url);

  /// Returns the tag with this [id], or `null` if there is none.
  Future<Tag?> findTagById(int id);

  /// Returns the tag named exactly [tagName], or `null` if there is none.
  ///
  /// Case-sensitive, for the same reason as [findFolderByName].
  Future<Tag?> findTagByName(String tagName);

  /// Returns the link between [urlId] and [tagId], or `null` if they aren't
  /// linked.
  Future<UrlTag?> findUrlTag(int urlId, int tagId);

  /// Number of URLs in each folder, keyed by folder id.
  ///
  /// Folders with no URLs are not in the map; read them as `counts[id] ?? 0`.
  Future<Map<int, int>> findUrlCountPerFolder();

  /// Number of URLs with each tag, keyed by tag id.
  ///
  /// Tags with no URLs are not in the map; read them as `counts[id] ?? 0`.
  Future<Map<int, int>> findUrlCountPerTag();

  /// Deletes all URL-tag links, URLs, tags and folders, in one transaction.
  /// Returns nothing.
  ///
  /// The default folder and tags are deleted too; call
  /// [seedDefaultFolderIfNotExist] and [seedDefaultTagsIfNotExist] afterwards
  /// to restore them.
  Future<void> clearAll();

  /// Saves [url] in [folder] with [tags], in one transaction, and returns the
  /// new URL's id.
  ///
  /// Special cases:
  /// - **Duplicate URL**: throws `DuplicateUrlException` and saves nothing if
  ///   the URL already exists. The database store checks by `id` when [url]
  ///   has one, otherwise by address; the mock store checks by address only.
  /// - **Folder**: if [folder] has an `id`, it is used as it is. Otherwise the
  ///   folder with the same name (case-sensitive) is used, or a new folder is
  ///   created if none exists.
  /// - **Tags**: each tag is resolved the same way as the folder (`id`, then
  ///   exact name, then created). A tag already linked to the URL, e.g. listed
  ///   twice in [tags], is linked only once.
  Future<int> createUrl({
    required Url url,
    required Folder folder,
    List<Tag> tags = const [],
  });

  /// Deletes everything (like [clearAll]), then saves each record the same
  /// way as [createUrl]. Returns the new URL ids in the same order as
  /// [records].
  ///
  /// Used to seed the database from Developer Options. Throws
  /// `DuplicateUrlException` if two records have the same URL; the database
  /// store then rolls back the whole operation, including the delete.
  /// The default folder and tags are not restored; seed them afterwards.
  Future<List<int>> clearAllAndCreateUrlFromRecords(List<UrlRecord> records);

  /// Inserts each folder in `AppDefaults.defaultFolders` whose name
  /// (case-sensitive) doesn't exist yet. Returns nothing.
  ///
  /// Safe to call on every app start: existing folders are left unchanged.
  Future<void> seedDefaultFolderIfNotExist();

  /// Inserts each tag in `AppDefaults.defaultTags` whose name (case-sensitive)
  /// doesn't exist yet. Returns nothing.
  ///
  /// Safe to call on every app start: existing tags are left unchanged.
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
