# Keep Links

A link management Flutter application for saving, reading, updating and deleting URLs.

The main goal of the application is to bring AI-based categorization and search to saved links.

## Documentation

- [Requirements](documents/requirements.md): functional and non-functional requirements, and what is out of scope.
- [How to Set Up the Project](documents/how_to_set_up_project.md): first-time setup, including `secrets.json` and the Mixpanel token.
- [Roadmap](documents/roadmap.md)
- [Database Schema](documents/database_schema.md)

## References

- To learn about URLs and their types, see MDN's [What is a URL?](https://developer.mozilla.org/en-US/docs/Learn_web_development/Howto/Web_mechanics/What_is_a_URL).

## Development Commands

### Set Up Secrets
Build-time secrets (such as the Mixpanel project token) live in `secrets.json` at the project root. This file is gitignored, so create it from the example and fill in your own values:
```bash
cp secrets.example.json secrets.json
```

| Key              | Description                                   |
|------------------|-----------------------------------------------|
| `MIXPANEL_TOKEN` | Mixpanel project token used for analytics.    |

The values are injected at build time with `--dart-define-from-file` and read in code through `BuildConfig` (`lib/core/utils/build_config.dart`). If the flag is omitted, the values are empty strings.

### Run the Application
Install dependencies, then run the app with the secrets file:
```bash
fvm flutter pub get
fvm flutter run lib/main.dart --dart-define-from-file=secrets.json
```

Pass the same flag when building a release, e.g.:
```bash
fvm flutter build apk --dart-define-from-file=secrets.json
fvm flutter build ipa --dart-define-from-file=secrets.json
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