import 'package:injectable/injectable.dart';
import 'package:keep_links/core/data/database/database_url_store.dart';
import 'package:keep_links/core/data/database/entity/folder.dart';
import 'package:keep_links/core/data/database/entity/tag.dart';
import 'package:keep_links/core/data/database/entity/url.dart';
import 'package:keep_links/core/data/database/entity/url_tag.dart';

export 'package:keep_links/core/data/database/database_url_store.dart';
export 'package:keep_links/core/data/database/mock_url_store.dart';
export 'package:keep_links/core/data/database/url_store_switcher.dart';

@lazySingleton
abstract class UrlStore {
  @factoryMethod
  factory UrlStore() => DatabaseUrlStore();

  // Insert Operations

  /// Inserts [folder] as it is and returns its id.
  ///
  /// Folder names are unique: if the name or `id` is already taken, the
  /// database store throws (unique constraint) and the mock store throws a
  /// [StateError]. Callers should check first (e.g. with [findFolderByName])
  /// to show a friendly message.
  Future<int> insertFolder(Folder folder);

  /// Inserts [tag] as it is and returns its id.
  ///
  /// Tag names are unique: if the name or `id` is already taken, the
  /// database store throws (unique constraint) and the mock store throws a
  /// [StateError]. Callers should check first (e.g. with [findTagByName]) to
  /// show a friendly message.
  Future<int> insertTag(Tag tag);

  /// Links a URL to a tag. Returns nothing.
  ///
  /// The database store throws if the same URL-tag link already exists, or if
  /// the URL or the tag doesn't exist (foreign keys). The mock store checks
  /// none of these: it adds the link as it is. Check with [findUrlTag],
  /// [findUrlById] and [findTagById] first.
  Future<void> insertUrlTag(UrlTag urlTag);

  // Query Operations

  /// Returns the folder of the URL with this [id].
  ///
  /// Returns `null` if the URL doesn't exist or its folder no longer exists.
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

  /// Returns the saved URL whose title is exactly [title], or `null` if there
  /// is none. Used for the duplicate check.
  ///
  /// Case-sensitive, for the same reason as [findFolderByName].
  Future<Url?> findUrlByTitle(String title);

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

  /// Deletes all URL-tag links, URLs, tags and folders. Returns nothing.
  ///
  /// The database store runs it in one transaction, so on failure nothing is
  /// deleted.
  ///
  /// The default folder and tags are deleted too; call
  /// [seedDefaultFolderIfNotExist] and [seedDefaultTagsIfNotExist] afterwards
  /// to restore them.
  Future<void> clearAll();

  /// Saves [url] in its folder (`url.folderId`) and links it to [tagIds].
  /// Returns the new URL's id.
  ///
  /// The only way to save a URL. Never creates folders or tags: they must
  /// already exist (the selection sheets create them). Everything is checked
  /// before anything is inserted, so on any failure nothing is saved. The
  /// database store also runs it in one transaction, and as a last resort its
  /// unique constraints reject a duplicate address or title, and its foreign
  /// keys reject a missing folder or tag.
  ///
  /// Special cases:
  /// - **Duplicate URL**: throws `DuplicateUrlException` if a URL with the
  ///   same address (or the same `id`, when [url] has one) already exists.
  /// - **Duplicate title**: throws `DuplicateTitleException` if a URL with
  ///   the same title already exists.
  /// - **Missing folder**: throws `FolderNotFoundException` if no folder has
  ///   `url.folderId`.
  /// - **Missing tag**: throws `TagNotFoundException` for the first id in
  ///   [tagIds] that has no tag.
  /// - **Repeated tag id**: an id listed twice in [tagIds] is linked once.
  Future<int> createUrl({
    required Url url,
    List<int> tagIds = const [],
  });

  /// Deletes the folder [sourceFolderId] and moves its URLs into the folder
  /// [targetFolderId]. Returns nothing.
  ///
  /// Checks run before anything changes, and the database store runs it in
  /// one transaction, so on failure nothing is moved or deleted. Folder and
  /// URL streams are notified.
  ///
  /// Special cases:
  /// - **Same folder**: throws `ArgumentError` if both ids are equal.
  /// - **Missing folder**: throws `FolderNotFoundException` if either folder
  ///   doesn't exist.
  /// - **Empty folder**: no URLs to move; the folder is just deleted.
  Future<void> deleteFolderAndMoveUrls({
    required int sourceFolderId,
    required int targetFolderId,
  });

  /// Deletes the tag [tagId] and all its URL-tag links. Returns nothing.
  ///
  /// URLs are never changed or deleted: each linked URL keeps its other
  /// tags, and a URL whose only tag was [tagId] is left with no tags. No
  /// other tag is linked in its place. The database store runs it in one
  /// transaction, so on failure nothing is deleted. Tag and URL-tag streams
  /// are notified.
  ///
  /// Special cases:
  /// - **Missing tag**: throws `TagNotFoundException` if no tag has [tagId].
  /// - **Unused tag**: no links to delete; the tag is just deleted.
  Future<void> deleteTagAndUrlTags(int tagId);

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
