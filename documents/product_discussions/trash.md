# Trash

Status: confirmed. Done so far: the `url.trash` column, and `findAllUrl()` leaves out trashed links. Checked tasks are done too.

## Goal

Deleting a link is never an accident. A deleted link goes to the trash, where the user can see it and either restore it or delete it permanently.

## Tasks

The tasks are in the order to build them.

1. [ ] **Saved or trashed:** a link is either **saved** (`url.trash = 0`) or **trashed** (`url.trash = 1`). A folder or tag is **trashed** (`trash = 1`) when the user deletes it while a trashed link still uses it.
2. [ ] **Schema changes:** update `database_schema.md` with every schema change. No migrations are needed during development; existing databases must be cleared after a schema change.
3. [x] **Uniqueness:** a trashed link doesn't reserve its URL or title, so the user can save the same ones again, and the trash may hold several links with the same URL or title.
    - `url` and `title` are unique only where `trash = 0`: remove the two unique indexes from `url.dart`, and create partial unique indexes (`WHERE trash = 0`) in Floor's `onCreate` callback.
    - Duplicate checks look at saved links only, in both stores. Do this together with the indexes, because allowing duplicates makes the unfiltered checks throw.
4. [x] **Visibility:** a trashed link appears only on the Trash page. It isn't in lists, counts or exports. The folder and tag selection sheets count saved links only.
5. [x] **Trash columns:** the `folder` and `tag` tables get a `trash` column (0 or 1), like `url`. The default folder (**Defaults**) and the default tag (**Tag1**) are never trashed.
6. [x] **Deleting a folder:** in the folder selection sheet, deleting a folder moves its saved links to **Defaults**. Its trashed links aren't touched. The folder is marked as trashed (`folder.trash = 1`) if a trashed link uses it. Otherwise it is permanently deleted.
7. [x] **Deleting a tag:** in the tag selection sheet, deleting a tag deletes its `url_tag` rows for saved links. A saved link keeps its other tags, possibly none. The `url_tag` rows of trashed links aren't touched. The tag is marked as trashed (`tag.trash = 1`) if a trashed link uses it. Otherwise it is permanently deleted.
8. [x] **Hiding trashed folders and tags:** they aren't in any list or selection sheet, and the number of folders and the number of tags don't include them. Their names are shown only on the cards of trashed links that use them.
    - A saved link never points to a trashed folder or tag: when saving a link, the stores treat a trashed folder or tag as missing.
9. [x] **Reusing a trashed name:** creating a folder or tag with the name of a trashed one makes the trashed one visible again (`trash = 0`) instead of adding a second one, because names are unique.
10. [ ] **No stale data:** verify that the `url`, `folder`, `tag` and `url_tag` tables hold no stale or unlinked data. This is a check only, done after tasks 13, 15 and 19. Folders and tags that aren't trashed are kept, even with no links, so they aren't stale.
11. [ ] **Timestamps:** verify that trashing a link sets `updated_at` to that time, and restoring it sets `updated_at` to the time of the restore. This is a check only, done after tasks 13 and 19. `created_at` never changes. There is no `trashed_at` column.
12. [x] **Reading the trash:** both stores have a query for trashed links with their folder and tags, including trashed folders and tags. The most recently trashed link comes first, ordered by `updated_at`.
13. [x] **Restoring:** both stores have one transactional `restoreUrl`. A restore either fully succeeds or changes nothing. Refer on how we are creating the url using `createUrl`
    - The link becomes saved again (`url.trash = 0`) with its original folder and tags. If its folder or any of its tags are trashed, they become visible again (`trash = 0`).
    - Accepted downside: a folder or tag deleted on purpose comes back when one of its links is restored.
    - Example: "Pasta" is saved in the folder **Recipes** with the tag **dinner**, then moved to the trash. **Recipes** is deleted: its saved links move to **Defaults**, and **Recipes** is marked as trashed. **dinner** is deleted and marked as trashed too. "Pasta" isn't touched. Restoring "Pasta" makes **Recipes** and **dinner** visible again, and "Pasta" is back in **Recipes** with the tag **dinner**.
14. [x] **Restore conflicts:** a restore is blocked if a saved link already has the same URL or title. The user can't rename the link to get around it. The URL is checked first, and the title only if the URL passes, so at most one clash is reported per attempt.
15. [ ] **Emptying the trash:** both stores have an operation that permanently deletes all trashed links and all trashed folders and tags. The links and their `url_tag` rows go first, then the trashed folders and tags that no link uses. It all runs in one transaction. It never touches the preview images, which stay in storage until the startup sweep removes them. See [startup_sweep.md](startup_sweep.md).
16. [ ] **No access to trashed links:** a trashed link can't be opened or edited. It can only be restored or permanently deleted.
17. [ ] **Trash page:** build it from the external design and the UI changes below.
    - The stores return the trashed links, their folders, their tags and their `url_tag` rows separately (task 12). `TrashBloc` combines them with this code. `TrashedUrl` goes in the same file, below `TrashBloc`.

    ```dart
    class TrashBloc extends Bloc<TrashEvent, TrashState> {
      // ...

      /// The trashed URLs with their folder and tags, kept up to date.
      Stream<List<TrashedUrl>> _watchTrashedUrls(UrlStore urlStore) {
        return urlStore.findTrashedUrls().asyncMap(
          (urls) async => _buildTrashedUrls(
            urls: urls,
            folders: await urlStore.findFoldersOfTrashedUrls(),
            tags: await urlStore.findTagsOfTrashedUrls(),
            urlTags: await urlStore.findUrlTagsOfTrashedUrls(),
          ),
        );
      }

      /// Combines each URL in [urls] with its folder and tags, keeping the
      /// order of [urls].
      ///
      /// A URL whose folder isn't in [folders] is left out: it was deleted
      /// after [urls] was read, and the next emission no longer has it.
      List<TrashedUrl> _buildTrashedUrls({
        required List<Url> urls,
        required List<Folder> folders,
        required List<Tag> tags,
        required List<UrlTag> urlTags,
      }) {
        final folderById = {for (final folder in folders) folder.id: folder};
        final tagById = {for (final tag in tags) tag.id: tag};
        final tagsByUrlId = <int, List<Tag>>{};
        for (final urlTag in urlTags) {
          final tag = tagById[urlTag.tagId];
          if (tag != null) {
            tagsByUrlId.putIfAbsent(urlTag.urlId, () => []).add(tag);
          }
        }

        final trashedUrls = <TrashedUrl>[];
        for (final url in urls) {
          final folder = folderById[url.folderId];
          if (folder == null) continue;
          trashedUrls.add(
            TrashedUrl(
              url: url,
              folder: folder,
              tags: tagsByUrlId[url.id] ?? const [],
            ),
          );
        }
        return trashedUrls;
      }
    }

    /// A URL in the trash with the folder and tags it returns to when restored.
    class TrashedUrl {
      TrashedUrl({required this.url, required this.folder, required this.tags});

      final Url url;

      /// May be trashed itself.
      final Folder folder;

      /// Any of them may be trashed.
      final List<Tag> tags;

      @override
      String toString() {
        return 'TrashedUrl{url: $url, folder: $folder, tags: $tags}';
      }
    }
    ```
18. [ ] **Entry point:** for now, the Trash page opens only from a button in Developer Options. Create no other entry point: the trash bin icon on the Folders page must not be wired to it, even once that icon is available.
19. [ ] **Move All Links to Trash:** this replaces Erase All Data, which deletes everything (`clearAll`).
    - All saved links move to the trash, and their `updated_at` is set to the current time. Links already in the trash keep their `updated_at`.
    - All folders and tags are deleted, except **Defaults** and **Tag1**. As in tasks 6 and 7, the ones a trashed link uses are marked as trashed, so restoring a link brings them back, and unused ones are permanently deleted.
20. [ ] **No automatic deletion:** no link is deleted automatically in version 1.
21. [ ] **Restore toasts:** `TrashBloc` handles every failed restore: it catches the exception from `restoreUrl`, logs it and shows a toast. Done with task 17, when `TrashBloc` exists.

    | Exception | Toast |
    |---|---|
    | `DuplicateUrlException` | "Duplicate link found" |
    | `DuplicateTitleException` | "Duplicate title found" |
    | `FolderNotFoundException` | "Folder does not exist" |
    | `TagNotFoundException` | "Tag does not exist" |
    | Anything else, including `UrlNotFoundException` | "Error While Restoring Link" |

## UI changes

These apply on top of the design from the external source.

- Each trashed link shows its preview image (or a placeholder), name, full URL, folder, and tags in a single scrollable line. Every card has the same fixed height.
- The folder and tags shown are the original ones, which the link returns to when restored, even if they have been deleted.
- Each card has a visible restore button.
- The Trash page has a delete icon that empties the trash. Pressing it shows a dialog asking whether to delete everything in the trash. Confirming permanently deletes all links in the trash, and all trashed folders and tags.
- Developer Options has a button that opens the Trash page.
- In Settings, "Erase All Data" and its warning dialog change to "Move All Links to Trash". The warning no longer says that the action can't be undone.
- In Settings, the Trash Retention card is hidden.

## Out of scope

- How a single link is moved to the trash. It is separate work.
- Permanently deleting a single link. It is separate work, right after restore. The link and its `url_tag` rows go first, then its trashed folder and tags if no other link, saved or trashed, uses them.
- Automatic deletion (trash retention).
