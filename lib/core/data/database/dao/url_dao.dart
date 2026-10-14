import 'package:floor/floor.dart';
import 'package:mindful_links/core/data/database/entity/folder.dart';
import 'package:mindful_links/core/data/database/entity/tag.dart';
import 'package:mindful_links/core/data/database/entity/url.dart';
import 'package:mindful_links/core/data/database/entity/url_tag.dart';
import 'package:mindful_links/core/data/database/exception/duplicate_url_exception.dart';

@dao
abstract class UrlDao {
  @Query('SELECT * FROM url')
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

  @insert
  Future<int> insertUrl(Url url);

  @insert
  Future<int> insertFolder(Folder folder);

  @insert
  Future<int> insertTag(Tag tag);

  @insert
  Future<void> insertUrlTag(UrlTag urlTag);

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

  @Query('SELECT * FROM url WHERE url = :url')
  Future<Url?> findUrlByUrlString(String url);

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
  Future<int> createUrl(Url url, Folder folder, List<Tag> tags) async {
    // 1. First step: Check if the URL already exists. If it does, abort immediately!
    final existingUrl = url.id != null
        ? await findUrlById(url.id!)
        : await findUrlByUrlString(url.url);

    if (existingUrl != null) {
      throw DuplicateUrlException(url.url);
    }

    // 2. Resolve folder: if ID is already known, use it directly; otherwise find by name or insert
    final int folderId;
    if (folder.id != null) {
      folderId = folder.id!;
    } else {
      final existingFolder = await findFolderByName(folder.folderName);
      if (existingFolder?.id != null) {
        folderId = existingFolder!.id!;
      } else {
        folderId = await insertFolder(folder);
      }
    }

    // 3. Insert the new URL with the resolved folderId
    final urlId = await insertUrl(url.copyWith(folderId: folderId));

    // 4. Resolve tags and link them via UrlTag
    for (final tag in tags) {
      final int tagId;
      if (tag.id != null) {
        tagId = tag.id!;
      } else {
        final existingTag = await findTagByName(tag.tagName);
        if (existingTag?.id != null) {
          tagId = existingTag!.id!;
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
}
