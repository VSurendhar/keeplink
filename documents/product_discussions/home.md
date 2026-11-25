# Home

Status: confirmed, not implemented.

| Thumbnail view | List view |
|---|---|
| ![Home in thumbnail view](images/home_thumbnail_view.png) | ![Home in list view](images/home_list_view.png) |

## 1. Intent

- **1.1** Home is where the user sees every saved link, finds one by search or tag, and adds a new one.
- **1.2** It must look like the same app as Settings and Add New Link.

## 2. Scope

**2.1** In scope:

- **2.1.1** The Home tab (`DashboardPage`): app bar, "Your Archive" heading, search bar, tag chips, view toggle, link list and FAB.
- **2.1.2** Showing a link saved from Add New Link once the user returns to Home.

**2.2** Out of scope:

- **2.2.1** Opening a link. Tapping a card does nothing yet.
- **2.2.2** Opening the Trash page. The trash icon does nothing yet.

## 3. Why

- **3.1** **Saved links only:** a trashed link belongs on the Trash page, so Home shows only links with `trash = 0`.
- **3.2** **Two views:** thumbnails are for recognising a link by its image, and the list fits more text.
- **3.3** **Search on title and URL:** the user may remember either one.
- **3.4** **Extra bottom space:** the last card must not be covered by the FAB or the bottom navigation bar.

## 4. What

- **4.1** **App bar:** centred title and a trash icon on the right. The title is "Keep Links", the app's current name, instead of the old name in the screenshot.
- **4.2** **Search bar:** hint "Search saved links...". Searches both title and URL.
- **4.3** **Tag chips:** "All Items", then one chip for each tag used by a saved link. Tags with no saved links aren't shown.
  - **4.3.1** Tapping a tag filters the list: only links with that tag are shown, and every other link is hidden.
  - **4.3.2** "All Items" removes the filter and shows all the saved links again.
  - **4.3.3** Search and tags apply together: while a tag is selected, search looks only in the links with that tag. With "All Items", it looks in all the saved links.
  - **4.3.4** Only one tag is selected at a time. Tapping another tag replaces the selected one.
  - **4.3.5** If a tag no longer has any saved links, or is deleted, its chip is removed. If it was the selected tag, "All Items" is selected and the search is kept. This happens whenever the tag data in the database changes, without a manual refresh.
- **4.4** **View toggle:** switches between the thumbnail view (grid) and the list view. The selected icon is highlighted. Every app start opens in the thumbnail view; the choice isn't saved.
- **4.5** **Card, in both views:** only the preview image, the title and the URL.
  - **4.5.1** Title: at most two lines, then an ellipsis.
  - **4.5.2** URL: one line, then an ellipsis.
  - **4.5.3** Image: cropped to fill a fixed shape: 1.91:1 in the thumbnail view, which shows the whole image, and square in the list view, which cuts off its sides. Thumbnail cards are therefore shorter than in the screenshot. With no image, or one that can't be read, a placeholder icon is shown.
- **4.6** **FAB:** opens Add New Link. After saving, the user is back on Home and the new link is shown.
  - **4.6.1** Saving a link selects "All Items" and clears the search, so the new link is never hidden. Leaving Add New Link without saving keeps the selected tag and the search.
- **4.7** **Order:** most recently changed first, by `updated_at`. Filtering and searching keep this order.
- **4.8** **Empty messages:** "No links saved yet" when there are no saved links, and "No links found" when the search and the selected tag match nothing.

## 5. How

- **5.1** **Data:** listen to `findAllUrl()`, so a newly saved link appears by itself. Resolve `UrlStore` from GetIt. The tag chips come from listening to `findAllTags()` and `findAllUrlTags()` together with `findAllUrl()`. Whenever any of them changes, the chips, the selected tag (4.3.5) and the list are worked out again.
- **5.2** **`trash = 0`:** build on `findAllUrl()` as it is now. It leaves out trashed links by itself once `feat/trash_page`, which adds the `url.trash` column and the filter, is merged. Until then, nothing can be in the trash on this branch.
- **5.3** **State:** a BLoC with the Action pattern, as in `lib/features/add_new_link/`, with separate event, action and state files.
- **5.4** **Icons:** `Symbols.tile_small` (thumbnail view), `Icons.view_list` (list view), `Icons.photo` (placeholder).
- **5.5** **Preview images:** `Image.file` with `BoxFit.cover`, shaped to `kPreviewImageAspectRatio` in the thumbnail view and to a square in the list view, using the path from `PreviewImageStorage.filePathFor`. It returns `null` until the folder has been resolved, which today happens only when an image is stored or deleted, so the folder must be resolved before Home shows images, or they would be missing after a restart.
- **5.6** **Colors and text styles:** reuse `KeepLinksTheme` and `KeepLinksColors`. Match Settings: `secondaryLight` background, centred 24 bold app bar title in `appBarTitleColor`, 24 semi-bold heading in `headerTitleColor`.
- **5.7** **Dimensions:** match Settings and Add New Link: 16 horizontal and 8 vertical page padding, 16 between sections, white cards with radius 16 and the same soft shadow. Follow the dimension rules for anything new.
- **5.8** **Bottom space:** the list's bottom padding is `paddingForBottomNavBar` plus the FAB's size and margin. The FAB sits above the bottom navigation bar.
- **5.9** **Errors:** handled in the BLoC, following the project's error handling rule.
- **5.10** **Knowing a link was saved:** Add New Link returns nothing to Home and isn't changed. Home learns about a new link from `findAllUrl()`: when an update has a link whose id wasn't in the previous one, Home resets the tag and search (4.6.1). The first load doesn't count.

## 6. Tasks

- [ ] **6.1** Load the links only through `findAllUrl()`, and check that trashed links are hidden once `feat/trash_page` is merged.
- [ ] **6.2** Make preview image paths available after an app restart.
- [ ] **6.3** Create the Home BLoC: listen to the links, tags and URL-tag streams, keep the links and chips up to date, and order the links by `updated_at`.
- [ ] **6.4** Build the app bar and the "Your Archive" heading. The trash icon does nothing: `// TODO: Wire it to the trash page once it is done.`
- [ ] **6.5** Build the search bar (title and URL).
- [ ] **6.6** Build the tag chips, and filter the list by the selected tag. When the database changes, remove the chip of a tag that disappears, and go back to "All Items" if it was selected (4.3.5).
- [ ] **6.7** Build the view toggle, starting in the thumbnail view.
- [ ] **6.8** Build the thumbnail card and grid, and the list card and list. The tap callback does nothing: `// TODO: Wire it when the link preview page is available.`
- [ ] **6.9** Add the FAB, opening Add New Link. When the stream brings a new link, select "All Items" and clear the search (4.6.1, 5.10).
- [ ] **6.10** Add the bottom padding for the navigation bar and the FAB.
- [ ] **6.11** Show the empty messages (4.8).
