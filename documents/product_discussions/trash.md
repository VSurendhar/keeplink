# Trash

Status: confirmed. Done so far: the `url.trash` column, and `findAllUrl()` leaves out trashed links. Everything else is not started.

## Goal

Deleting a link is never an accident. A deleted link goes to the trash, where the user can see it and either restore it or delete it permanently.

## Tasks

The tasks are in the order to build them.

1. [ ] **Saved or trashed:** a link is either **saved** (`url.trash = 0`) or **trashed** (`url.trash = 1`). Folders and tags are never trashed.
2. [ ] **Schema changes:** update `database_schema.md` with every schema change. No migrations are needed during development; existing databases must be cleared after a schema change.
3. [ ] **Uniqueness:** a trashed link doesn't reserve its URL or title, so the user can save the same ones again, and the trash may hold several links with the same URL or title.
    - `url` and `title` are unique only where `trash = 0`: remove the two unique indexes from `url.dart`, and create partial unique indexes (`WHERE trash = 0`) in Floor's `onCreate` callback.
    - Duplicate checks look at saved links only, in both stores. Do this together with the indexes, because allowing duplicates makes the unfiltered checks throw.
4. [ ] **Visibility:** a trashed link appears only on the Trash page. It isn't in lists, counts or exports. The folder and tag selection sheets count saved links only.
5. [ ] **Remembering a deleted folder:** deleting a folder moves its trashed links too, so the original folder's name is stored on the trashed link and cleared on restore.
6. [ ] **Remembering a deleted tag:** deleting a tag removes its links, so the deleted tag's name is kept for each trashed link in a small table.
7. [ ] **Timestamps:** trashing a link sets `updated_at` to that time, and restoring it sets `updated_at` to the time of the restore. `created_at` never changes. There is no `trashed_at` column.
8. [ ] **Reading the trash:** both stores have a query for trashed links with their folder and tags. The most recently trashed link comes first, ordered by `updated_at`.
9. [ ] **Restoring:** both stores have one transactional `restoreUrl`. A restore either fully succeeds or changes nothing.
    - It brings back the link with its folder and tags. A folder or tag deleted while the link was in the trash is recreated, or reused if one with the same name exists. The link isn't restored into the folder it was moved to.
    - Accepted downside: a folder or tag deleted on purpose comes back when one of its links is restored.
    - Example: "Pasta" is saved in the folder **Recipes** with the tag **dinner**, then moved to the trash. **Recipes** is deleted, its links are moved to **Defaults**, and **dinner** is deleted too. Restoring "Pasta" creates **Recipes** and **dinner** again, and "Pasta" is back in **Recipes** with the tag **dinner**.
10. [ ] **Restore conflicts:** a restore is blocked with a message if a saved link already has the same URL or title. The user can't rename the link to get around it. The URL is checked first, and the title only if the URL passes, so at most one clash is reported per attempt. The toast says "Duplicate link found" or "Duplicate title found".
11. [ ] **Emptying the trash:** both stores have an operation that permanently deletes all trashed links, and only the links. It never touches the preview images, which stay in storage until the startup sweep removes them. See [startup_sweep.md](startup_sweep.md).
12. [ ] **No access to trashed links:** a trashed link can't be opened or edited. It can only be restored or permanently deleted.
13. [ ] **Trash page:** build it from the external design and the UI changes below.
14. [ ] **Entry point:** for now, the Trash page opens only from a button in Developer Options. Create no other entry point: the trash bin icon on the Folders page must not be wired to it, even once that icon is available.
15. [ ] **Move All Links to Trash:** this replaces Erase All Data, which deletes everything (`clearAll`).
    - All saved links move to the trash, and their `updated_at` is set to the current time. Links already in the trash keep their `updated_at`.
    - All folders and tags are deleted, except the default folder (**Defaults**) and the default tag (**Tag1**). Their names are remembered, so restoring a link recreates them.
16. [ ] **No automatic deletion:** nothing is deleted automatically in version 1.

## UI changes

These apply on top of the design from the external source.

- Each trashed link shows its preview image (or a placeholder), name, full URL, folder, and tags in a single scrollable line. Every card has the same fixed height.
- The folder and tags shown are the original ones, which the link returns to when restored, even if they have been deleted.
- Each card has a visible restore button.
- The Trash page has a delete icon that empties the trash. Pressing it shows a dialog asking whether to delete everything in the trash. Confirming permanently deletes all links in the trash.
- Developer Options has a button that opens the Trash page.
- In Settings, "Erase All Data" and its warning dialog change to "Move All Links to Trash". The warning no longer says that the action can't be undone.
- In Settings, the Trash Retention card is hidden.

## Out of scope

- How a single link is moved to the trash. It is separate work.
- Permanently deleting a single link. It is separate work, right after restore.
- Automatic deletion (trash retention).
