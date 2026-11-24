# Startup Sweep

Status: planned, not implemented.

The planned startup cleanup deletes preview images in the `keep_links/` folder that no link uses.

## Must not remove images of trashed links

- A link's preview image stays in storage while the link is in the trash. Trashing and restoring only change `url.trash`; they never touch the image. See [trash.md](trash.md).
- Treat the image as in use until the link is permanently deleted.
- `findAllUrl()` returns only untrashed links, so the cleanup must not use it alone to decide which images are in use. It must check trashed links too.

## Later: deleting trashed links (after version 1)

- Once the trash retention period ends, the sweep will permanently delete the trashed link and its preview image together.
- This is not part of version 1, where nothing is deleted from the trash automatically.
