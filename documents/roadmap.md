# Roadmap

## Version 1

Version 1 covers only the basic CRUD operations on links.

### Included

- **Create a link**:
  - The user enters the title and the URL manually.
  - The link is saved into a folder.
  - The link can have tags, or no tags.
  - New folders and tags can be created while saving a link.
- **Receive links shared from other apps**: a link shared to the app from another app opens the create-link flow.
- **Read links**:
  - The home screen shows the saved links. The user can search them by title and URL, and tap a tag to show only its links. See [home.md](product_discussions/home.md).
  - The folder screen shows all folders. Tapping a folder opens a screen with the links saved in it.
- **Update a link**: edit a saved link.
- **Delete a link**: a deleted link moves to the trash folder.
- **Trash folder**: the user opens it to restore links or delete them permanently. Nothing is deleted automatically.
- **Duplicate checks**:
  - A URL that is already saved can't be saved again.
  - A title that is already used can't be used again.
  - Folder names and tag names must be unique.
- **Settings**: only the Erase All Data option.
- **Crash analytics.**
- **Analytics with Mixpanel.**
- **Developer Options tab.**
- **Logging options.**

### Not Included

- Crawling the URL for metadata: no preview image, meta title or meta description.
- AI-based operations of any kind.
- Sorting of any kind, including on the home and folder screens, and by tags or link IDs.
- Searching or filtering links anywhere other than the home screen, and filtering by anything other than a tag.
- Favourite links. The `is_favorite` column stays in the database for future versions.
- Settings other than Erase All Data:
  - Theme switching or skin changes.
  - Language selection (localization).
  - Data backup (export and import).
  - Trash retention (automatic deletion from the trash).
