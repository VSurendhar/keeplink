# Keep Links

A link management Flutter application for saving, reading, updating and deleting URLs.

The main goal of the application is to bring AI-based categorization and search to saved links.

## Requirements

### Functional Requirements

- Save a link.
- Save every link exactly as the user entered it (only surrounding spaces are trimmed). Validation never changes the saved link.
- A link is a duplicate only when its text exactly matches a saved link. `example.com` and `https://example.com` are different links.
- Accept only absolute URLs, e.g. `https://example.com/page`. Relative URLs such as `./page`, `../page`, `?q=1` or `#section` are rejected. Text starting with `/` is accepted as a Mac or Linux path (see below), so a website-relative link like `/blog/post` is saved too.
- Accept bare domains without a scheme, e.g. `example.com` or `babies.com`. The domain must be valid: no spaces and no empty parts (`a..com`). Without a scheme the domain needs a dot, so a single word like `notes` is rejected; `localhost` is the exception.
- Accept servers without a dot when the scheme is typed, e.g. `https://localhost/user/1234` or `http://intranet/wiki`.
- Accept file paths, saved as a note of where something lives even if the app can't open them:
  - Absolute Windows paths, e.g. `C:\Users\me` or `c:/Users/me`. Drive-relative paths such as `C:Users` are rejected.
  - Windows network paths, e.g. `\\server\share\a.txt`.
  - Mac and Linux paths from the root or the home folder, e.g. `/home/me/notes.md` or `~/Documents`.
  - Any `file:` link with a path, e.g. `file:///C:/Users/me`, `file:///sdcard/a.txt` or `file://server/share/a.txt`.
- Accept Android and iOS deep links, including reverse-DNS schemes such as `com.example.app:/callback`.
- Reject Data URLs (`data:`), Blob URLs (`blob:`) and JavaScript URLs (`javascript:`).
- Reject device-local links that stop working once saved: `content:`, `asset:`, `resource:` and `android.resource:`.
- A simple web crawler that fetches the link's metadata: meta image, meta title and meta description.
- Show a description for each link, taken from its meta description or allow user to insert his own.
- Tag links and create folders.
- Delete, modify, search and sort links and folders by keywords, selection and tags.
- Change the theme and language, and save user preferences.
- Cache the metadata image in private storage.
- Retry fetching metadata with a deferred work request when the network is unavailable.
- Refresh button for metadata images.
- TTL for the cache.
- Export and import.
- Analytics with Google Analytics or Mixpanel.
- Store logs in a local file.
- Trash.
- AI-based categorization and search.

### Non-Functional Requirements

- Save any number of links while avoiding duplicates.
- Run on both Android and iOS, built with Flutter.
- Security: never open a saved URL in a WebView, and never render or execute the content a URL points to. The metadata crawler may fetch a page only to read its meta title, meta description and meta image. It must not run scripts, render the page, or download, decode or process any other resource.
- Data URLs are not supported because they embed the resource content itself, which makes them large (Base64 encoding alone adds about 33% to the data's size). Storing such payloads in SQLite would increase database size, disk I/O and memory use, and passing them to future AI integrations as plain text would waste input tokens and raise processing costs. Keep Links manages links, not embedded resources, so supporting them adds overhead with no functional benefit.

### Out of Scope

- User authentication, accounts, or saving links on a remote server.
- Saving links from other sources such as Telegram or Slack bots.
- An eviction policy for cached image metadata.
- TinyURL integration.

## References

- To learn about URLs and their types, see MDN's [What is a URL?](https://developer.mozilla.org/en-US/docs/Learn_web_development/Howto/Web_mechanics/What_is_a_URL).

## Development Commands

### Run the Application
```bash
fvm flutter run lib/main.dart
```

### Run Code Generation (`build_runner`)
Generate database code and dependency injection files while removing conflicting outputs:
```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

### Run Code Format
Format code under lib directory to maintain the uniform formatting practice
```bash
fvm dart format lib/
```