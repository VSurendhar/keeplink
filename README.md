# Mindful Links

A mindful link management Flutter application for saving, reading, updating and deleting URLs.

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