# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Keep Links is a Flutter link-management app for saving, reading, updating and deleting URLs (Android + iOS). Project coding rules live in `.claude/rules/` and are loaded automatically — follow them (BLoC file layout, no `!`, `toString()` on models, dimension values, `@lazySingleton`, never edit generated files, run `dart analyze` after changes).

## Commands

The project uses FVM; prefix `flutter`/`dart` with `fvm`.

```bash
fvm flutter pub get
fvm flutter run lib/main.dart                                  # single entry point (debug enables dev features)
fvm dart run build_runner build --delete-conflicting-outputs   # regenerate Floor, injectable, Hive adapters
fvm dart analyze <changed_files>                               # required after Dart changes
```

Run `build_runner` after touching anything annotated for codegen: Floor entities/DAO/`@Database` (`*.g.dart`), `@injectable`/`@lazySingleton` classes (`lib/core/di/injection.config.dart`), or Hive `@HiveType` models.

## Architecture

**Startup (`lib/main.dart`)**: sets `BuildConfig.isDevelopmentBuild` from `kDebugMode`, installs `AppBlocObserver` in dev/debug, routes `FlutterError`/`PlatformDispatcher` errors to `logError`, then `configureDependencies()` (GetIt init → `HiveService.init()` → `initLogger()`) and seeds the default folder/tags via `UrlStore`. `App` → `MaterialApp` with `KeepLinksTheme.light` and `HomePage`.

**Dependency injection**: `get_it` + `injectable` (`lib/core/di/`). Widgets resolve dependencies with `GetIt.instance.get<T>()` when creating their BLoC in `BlocProvider`, and pass them into the BLoC constructor (e.g. `AppSettingsPage`, the folder/tag selection sheets).

**Two persistence layers**:
- **Links data — Floor (SQLite)** in `lib/core/data/database/`. Entities `Url`, `Folder`, `Tag`, `UrlTag` (many-to-many join), single `UrlDao`, `UrlDatabase` (`keep_links_db.db`, version 1). All access goes through the abstract `UrlStore` interface; `UrlStore()` factory returns `DatabaseUrlStore`, and `MockUrlStore` is an in-memory alternative. `UrlStoreSwitcher` swaps the GetIt registration at runtime (used by Developer Options), so always resolve `UrlStore` from GetIt rather than holding a concrete implementation. Importing `url_store.dart` re-exports both implementations and the switcher.
- **Settings — Hive** in `lib/core/data/hive/`. One box (`app_settings`) opened in `HiveService.init()`, keys in `constant.dart`, enums `AppTheme`/`AppLanguage` with generated adapters. Read/write only via `AppSettingsService` (`lib/features/settings/service/`).

**Features (`lib/features/<feature>/`)**: `bloc/` (or `cubit/`) + `view/` + `view/widgets/`. Nested flows (e.g. `add_new_link/bottom_sheets/folder_selection_sheet/`) repeat the same bloc/view structure, with a `show_*_sheet.dart` entry function that provides the BLoC.

**BLoC "Action" pattern** — one-off UI side effects (navigation, dialogs, sheets, toasts) are modeled as a sealed `XxxAction` class carried in the state's nullable `action` field, not as separate streams:
1. Handler emits `state.copyWith(action: SomeAction())`.
2. View uses `BlocConsumer` with `listenWhen: current.action != null && previous.action != current.action`, switches on the action type, then dispatches `OnActionHandled`.
3. `OnActionHandled` emits `copyWith(clearAction: true)`.

See `lib/features/add_new_link/` as the reference implementation. States extend `Equatable` and expose `copyWith`; events are named `On...` (e.g. `OnSaveClicked`). Loading on open is an `OnInitEvent` that the page dispatches when creating the BLoC (`..add(const OnInitEvent())`); BLoCs can only `emit` inside event handlers, so don't load or emit from plain methods.

**Home / navigation**: `HomeCubit` drives the bottom nav (`HomeTab`); the Developer Options tab is only shown when `BuildConfig.isDeveloperOrDebug`. Pages are pushed inline with `Navigator.of(context).push(MaterialPageRoute<void>(builder: ...))`; there are no static `route(...)` helpers.

**Developer options (`lib/features/developer_options/`)**: toggles mock vs. real `UrlStore`; `DeveloperOptionsCubit` itself seeds and prints the database and initializes default settings via `AppSettingsService`.

**Shared code**: theme/colors in `lib/features/theme/` (`KeepLinksTheme`, `KeepLinksColors`), logging via `lib/features/logger/logger.dart` (`logError` etc.), toasts via `Utils.showToast` (`lib/utils/utils.dart`), defaults in `lib/core/app_defaults.dart`.

**Tests**: `test/` currently only holds an empty placeholder `widget_test.dart` and we don't use tests in this project.
