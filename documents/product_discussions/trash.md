# Trash

Status: confirmed. Done so far: the `url.trash` column, and `findAllUrl()` leaves out trashed links. The issues below are not started.

## Goal

Deleting a link is never an accident. A deleted link goes to the trash, where the user can see it and either restore it or delete it permanently.

## Rules

1. A link is either **saved** (`url.trash = 0`) or **trashed** (`url.trash = 1`). Folders and tags are never trashed.
2. A trashed link appears only on the Trash page. It isn't in lists, counts or exports.
3. A trashed link doesn't reserve its URL or title: the user can save the same ones again.
4. The trash may hold several links with the same URL or title.
5. Restoring brings back the link with its folder and tags. A missing folder or tag is recreated, or reused if one with the same name exists.
6. A restore either fully succeeds or changes nothing.
7. A restore is blocked if a saved link already has the same URL or title, and the user is told which. The URL is checked first, and the title only if the URL passes, so at most one clash is reported per attempt. The toast says "Duplicate link found" or "Duplicate title found".
8. Nothing is deleted automatically in version 1.
9. A trashed link can't be opened or edited. It can only be restored or permanently deleted.
10. Trashing a link sets `updated_at` to that time. Restoring a link also sets `updated_at` to the time of the restore. `created_at` never changes.
11. The Trash page lists the most recently trashed link first, ordered by `updated_at`. There is no `trashed_at` column.
12. Erase All Data becomes **Move All Links to Trash**:
    - All saved links move to the trash, and their `updated_at` is set to the current time. Links already in the trash keep their `updated_at`.
    - All folders and tags are deleted, except the default folder (**Defaults**) and the default tag (**Tag1**). Their names are remembered, so restoring a link recreates them.
13. Emptying the trash permanently deletes the links only. It never touches the preview images, which stay in storage until the startup sweep removes them. See [startup_sweep.md](startup_sweep.md).

## UI changes

These apply on top of the design from the external source.

- Each trashed link shows its preview image (or a placeholder), name, full URL, folder, and tags in a single scrollable line. Every card has the same fixed height.
- The folder and tags shown are the original ones, which the link returns to when restored, even if they have been deleted.
- The Trash page has a delete icon that empties the trash. Pressing it shows a dialog asking whether to delete everything in the trash. Confirming permanently deletes all links in the trash.
- For now, a button in Developer Options is the only entry point to the Trash page. Create no other entry point: the trash bin icon on the Folders page must not be wired to it, even once that icon is available.
- In Settings, the Trash Retention card is hidden.
- In Settings, "Erase All Data" and its warning dialog change to "Move All Links to Trash". The warning no longer says that the action can't be undone.

## Issues

| # | Issue | Fix |
|---|---|---|
| 1 | `url` and `title` are unique across the whole table, so rules 3 and 4 fail in SQLite (blocker) | Unique only where `trash = 0`: remove the two unique indexes from `url.dart`, and create partial unique indexes (`WHERE trash = 0`) in Floor's `onCreate` callback |
| 2 | Deleting a folder moves its trashed links too, so the original folder is forgotten (blocker) | Store the original folder's name on the trashed link and clear it on restore |
| 3 | Deleting a tag removes its links, so the tag is forgotten (blocker) | Keep the deleted tag's name for each trashed link in a small table |
| 4 | Duplicate checks include trashed links | Check saved links only, in both stores |
| 5 | The folder and tag selection sheets count trashed links | Count saved links only |
| 6 | There is no restore operation | Add one transactional `restoreUrl` to both stores, which also sets `updated_at` |
| 7 | There is no query for trashed links with their folder and tags | Add one to both stores, ordered by `updated_at`, newest first |
| 8 | Erase All Data deletes everything (`clearAll`) | Replace it with Move All Links to Trash (rule 12), and update its UI in Settings |
| 9 | There is no operation to empty the trash | Add one to both stores that deletes the links but not their preview images (rule 13) |
| 10 | `database_schema.md` goes out of date | Update it with every schema change |
| 11 | There is no Trash page | Build it from the external design and the UI changes above, with the restore button on each card and the delete icon |
| 12 | The Trash page has no entry point | Open it from a button in Developer Options only |
| 13 | The Trash Retention card offers automatic deletion (rule 8) | Hide it in Settings |

Suggested order: 1 and 4 together (allowing duplicates makes the unfiltered duplicate checks throw), then 5, then 2 and 3, then 7, 6 and 9, then 11 and 12, then 8 and 13. Issue 10 goes along with each schema change.

No migrations are needed during development; existing databases must be cleared after a schema change.

## Confirmed decisions

### Deleted folder and tags: recreate

If a link's folder or tags were deleted while it was in the trash, restoring the link creates them again and links them to it. If a folder or tag with the same name exists, it is reused.

Example:

1. "Pasta" is saved in the folder **Recipes** with the tag **dinner**, then moved to the trash.
2. The folder **Recipes** is deleted and its links are moved to **Defaults**. The tag **dinner** is deleted too.
3. "Pasta" is restored: **Recipes** and **dinner** are created again, and "Pasta" is back in **Recipes** with the tag **dinner**.

- The names must be remembered while the link is in the trash (issues 2 and 3).
- Accepted downside: a folder or tag deleted on purpose comes back when one of its links is restored.
- Rejected option: restore the link into the folder it was moved to (**Defaults**), without its deleted tags.

### Other decisions

| # | Question | Decision |
|---|---|---|
| 1 | On a restore conflict, block, or allow a rename when only the title clashes? | Block with a message |
| 2 | How does the user restore a link? | A visible restore button on each card |
| 3 | Is permanently deleting a single link part of this work? | Separate work, right after restore |
| 4 | Is emptying the trash part of this work? | Yes, with the delete icon on the Trash page |
| 5 | Add a `trashed_at` column? | No, use `updated_at` |
| 6 | Can a trashed link be opened? | No |
| 7 | Where is the Trash page opened from? | For now, only a button in Developer Options, not the trash bin icon on the Folders page |
| 8 | Does Move All Links to Trash delete folders and tags? | Yes, Move all links , tags , folders |
| 9 | Keep the Trash Retention card in Settings? | No, hide it |

## Out of scope

- How a single link is moved to the trash. It is separate work.
- Permanently deleting a single link. It is separate work, right after restore.
- Automatic deletion (trash retention).
