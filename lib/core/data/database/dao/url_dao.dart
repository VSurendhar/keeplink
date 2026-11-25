import 'package:floor/floor.dart';
import 'package:keep_links/core/data/database/entity/folder.dart';
import 'package:keep_links/core/data/database/entity/tag.dart';
import 'package:keep_links/core/data/database/entity/url.dart';
import 'package:keep_links/core/data/database/entity/url_tag.dart';
import 'package:keep_links/core/data/database/exception/duplicate_title_exception.dart';
import 'package:keep_links/core/data/database/exception/duplicate_url_exception.dart';
import 'package:keep_links/core/data/database/exception/folder_not_found_exception.dart';
import 'package:keep_links/core/data/database/exception/tag_not_found_exception.dart';
import 'package:keep_links/core/utils/app_defaults.dart';

@dao
abstract class UrlDao {
  @Query('SELECT * FROM url WHERE trash = 0')
  Stream<List<Url>> findAllUrl();

  @Query(
    'SELECT * FROM folder f where f.id = (SELECT folder_id FROM url u WHERE u.id = :id)',
  )
  Future<Folder?> findFolderForUrlId(int id);

  @Query('SELECT * FROM url_tag')
  Stream<List<UrlTag>> findAllUrlTags();

  @Query('SELECT * FROM tag')
  Stream<List<Tag>> findAllTags();

  @Query('SELECT * FROM folder')
  Stream<List<Folder>> findAllFolders();

  /// One `folder_id` per saved URL, for counting URLs per folder.
  @Query('SELECT folder_id FROM url WHERE trash = 0')
  Future<List<int>> findAllUrlFolderIds();

  /// One `tag_id` per tag link of a saved URL, for counting URLs per tag.
  @Query(
    'SELECT tag_id FROM url_tag WHERE url_id IN (SELECT id FROM url WHERE trash = 0)',
  )
  Future<List<int>> findAllUrlTagIds();

  /// Internal to [createUrl], which validates the URL first; call
  /// [createUrl] instead of this.
  @insert
  Future<int> insertUrl(Url url);

  @insert
  Future<int> insertFolder(Folder folder);

  @insert
  Future<int> insertTag(Tag tag);

  @insert
  Future<void> insertUrlTag(UrlTag urlTag);

  @Query('SELECT * FROM url WHERE folder_id = :folderId')
  Future<List<Url>> findUrlsByFolderId(int folderId);

  @update
  Future<void> updateUrls(List<Url> urls);

  @update
  Future<void> updateFolder(Folder folder);

  @delete
  Future<void> deleteFolder(Folder folder);

  @Query('SELECT * FROM url_tag WHERE tag_id = :tagId')
  Future<List<UrlTag>> findUrlTagsByTagId(int tagId);

  /// The tag links of saved URLs with this tag.
  @Query(
    'SELECT * FROM url_tag WHERE tag_id = :tagId AND url_id IN (SELECT id FROM url WHERE trash = 0)',
  )
  Future<List<UrlTag>> findSavedUrlTagsByTagId(int tagId);

  @delete
  Future<void> deleteUrlTags(List<UrlTag> urlTags);

  @update
  Future<void> updateTag(Tag tag);

  @delete
  Future<void> deleteTag(Tag tag);

  @Query('DELETE FROM url_tag')
  Future<void> deleteAllUrlTags();

  @Query('DELETE FROM url')
  Future<void> deleteAllUrls();

  @Query('DELETE FROM tag')
  Future<void> deleteAllTags();

  @Query('DELETE FROM folder')
  Future<void> deleteAllFolders();

  @Query('SELECT * FROM folder WHERE id = :id')
  Future<Folder?> findFolderById(int id);

  @Query('SELECT * FROM folder WHERE folder_name = :folderName')
  Future<Folder?> findFolderByName(String folderName);

  @Query('SELECT * FROM url WHERE id = :id')
  Future<Url?> findUrlById(int id);

  @Query('SELECT * FROM url WHERE url = :url AND trash = 0')
  Future<Url?> findUrlByUrlString(String url);

  @Query('SELECT * FROM url WHERE title = :title AND trash = 0')
  Future<Url?> findUrlByTitle(String title);

  @Query('SELECT * FROM tag WHERE id = :id')
  Future<Tag?> findTagById(int id);

  @Query('SELECT * FROM tag WHERE tag_name = :tagName')
  Future<Tag?> findTagByName(String tagName);

  @Query('SELECT * FROM url_tag WHERE url_id = :urlId AND tag_id = :tagId')
  Future<UrlTag?> findUrlTag(int urlId, int tagId);

  @transaction
  Future<void> clearAll() async {
    await deleteAllUrlTags();
    await deleteAllUrls();
    await deleteAllTags();
    await deleteAllFolders();
  }

  @transaction
  Future<int> createUrl(Url url, List<int> tagIds) async {
    // Validate everything before inserting, so nothing is saved on failure.
    await checkIfUrlExists(url);
    await checkIfFolderExists(url.folderId);
    final uniqueTagIds = tagIds.toSet();
    await checkIfTagsExist(uniqueTagIds);

    final urlId = await insertUrl(url);
    for (final tagId in uniqueTagIds) {
      await insertUrlTag(UrlTag(urlId: urlId, tagId: tagId));
    }
    return urlId;
  }

  @transaction
  Future<void> deleteFolderAndMoveUrls(
    int sourceFolderId,
    int targetFolderId,
  ) async {
    if (sourceFolderId == targetFolderId) {
      throw ArgumentError('Cannot move URLs into the folder being deleted');
    }
    await checkIfFolderExists(targetFolderId);
    final folder = await findFolderById(sourceFolderId);
    if (folder == null) {
      throw FolderNotFoundException(sourceFolderId);
    }
    if (AppDefaults.isDefaultFolder(folder)) {
      throw ArgumentError('Cannot delete the default folder');
    }

    final urls = await findUrlsByFolderId(sourceFolderId);
    await updateUrls(
      urls
          .where((url) => !url.trash)
          .map((url) => url.copyWith(folderId: targetFolderId))
          .toList(),
    );
    // Trashed URLs stay in the folder, so it's kept for restoring them.
    if (urls.any((url) => url.trash)) {
      await updateFolder(folder.copyWith(trash: true));
    } else {
      await deleteFolder(folder);
    }
  }

  @transaction
  Future<void> deleteTagAndUrlTags(int tagId) async {
    final tag = await findTagById(tagId);
    if (tag == null) {
      throw TagNotFoundException(tagId);
    }
    if (AppDefaults.isDefaultTag(tag)) {
      throw ArgumentError('Cannot delete the default tag');
    }

    await deleteUrlTags(await findSavedUrlTagsByTagId(tagId));
    // Trashed URLs keep their tag links, so the tag is kept for restoring them.
    final trashedUrlTags = await findUrlTagsByTagId(tagId);
    if (trashedUrlTags.isNotEmpty) {
      await updateTag(tag.copyWith(trash: true));
    } else {
      await deleteTag(tag);
    }
  }

  /// Throws [DuplicateUrlException] if any URL has the same id or a saved URL
  /// has the same address, or [DuplicateTitleException] if a saved URL has the
  /// same title.
  ///
  /// A trashed [url] may share its address and title with any other URL, so
  /// only its id is checked.
  Future<void> checkIfUrlExists(Url url) async {
    final id = url.id;
    final idTaken = id != null && await findUrlById(id) != null;
    if (idTaken) {
      throw DuplicateUrlException(url.url);
    }
    if (url.trash) return;

    if (await findUrlByUrlString(url.url) != null) {
      throw DuplicateUrlException(url.url);
    }
    if (await findUrlByTitle(url.title) != null) {
      throw DuplicateTitleException(url.title);
    }
  }

  /// Throws [FolderNotFoundException] if no folder has [folderId].
  Future<void> checkIfFolderExists(int folderId) async {
    if (await findFolderById(folderId) == null) {
      throw FolderNotFoundException(folderId);
    }
  }

  /// Throws [TagNotFoundException] for the first id in [tagIds] with no tag.
  Future<void> checkIfTagsExist(Iterable<int> tagIds) async {
    for (final tagId in tagIds) {
      if (await findTagById(tagId) == null) {
        throw TagNotFoundException(tagId);
      }
    }
  }
}
