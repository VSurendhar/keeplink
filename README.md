# Mindful Links

A mindful link management and bookmarking Flutter application.

## Development Commands

### Run in Development Mode
```bash
fvm flutter run lib/main_developement.dart
```

### Run Code Generation (`build_runner`)
Generate database code and dependency injection files while removing conflicting outputs:
```bash
fvm dart run build_runner build --delete-conflicting-outputs
```