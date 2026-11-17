# Mindful Links

A mindful link management Flutter application for saving, reading, updating and deleting URLs.

The main goal of the application is to bring AI-based categorization and search to saved links.

## Requirements

### Functional Requirements

- Save a link.
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

### Out of Scope

- User authentication, accounts, or saving links on a remote server.
- Saving links from other sources such as Telegram or Slack bots.
- An eviction policy for cached image metadata.
- TinyURL integration.

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