---
trigger: always_on
description: Wrap every database/Hive operation in try/catch in the business layer (BLoC/Cubit), never in the store or service layer
---

# Handle database errors in the business layer

Every database (Floor / `UrlStore`) and Hive (`AppSettingsService`) operation must run inside a
`try/catch` in the **business layer**: BLoCs, Cubits.

Do **not** add `try/catch` in the store, DAO, service, or UI layer. Those layers let errors
propagate so the business layer can decide what the user sees.

## Rules

1. Wrap every `await` on a store/service call in `try/catch`, including reads (`find...().first`),
   writes (`insert...`, `save...`, `clearAll`), and seeding.
2. In `catch (e, st)`:
   - Log with `logError('<what failed>', e, stackTrace: st)`.
   - Emit a user-facing result via the feature's `ShowToast` action (or equivalent) when the user
     triggered the operation.
   - Reset any in-progress state (`isSaving`, `isLoading`, ...), using `finally` when it must
     always happen.
3. Show success feedback (toasts, closing sheets, updating persisted state) only **after** the
   awaited operation succeeds, inside the `try`.
4. For streams consumed with `emit.forEach`, the `onError` callback must log the error, not silently
   swallow it.
5. Hive:
   - **Writes** (`put`, `delete`, `clear`) and **opening** (`Hive.initFlutter`, `Hive.openBox`)
     need `try/catch` as above. Opening runs before `runApp`, so rule 7 applies.
   - **Reads** (`box.get`) do **not** need `try/catch`: an open box is held in memory, so `get`
     doesn't touch the disk. Instead, type-check the value and fall back to `AppDefaults`, so a
     missing or wrongly typed value (e.g. left by an older app version) can't throw a `TypeError`.
     See [Hive reads](#hive-reads).
6. Do not put store/service calls in a `finally` block unless they are themselves guarded; errors
   thrown in `finally` escape the `try`.
7. Startup code that runs before `runApp` (`bootstrap`, DI init, seeding) must catch its own errors,
   so a failure is logged without preventing `runApp` from running.
8. The global `FlutterError.onError` / `PlatformDispatcher.instance.onError` handlers are a
   last-resort logger, not error handling: they run after the failing code has already stopped and
   cannot resume it.

## Exception

A data-layer `try/catch` is allowed only for internal cleanup that **rethrows**, e.g. resetting a
cached `Future` so the next call can retry:

```dart
class DatabaseUrlStore {
  Future<UrlDatabase>? _dbFuture;

  Future<UrlDatabase> _buildDatabase() async {
    try {
      return await $FloorUrlDatabase.databaseBuilder('db.db').build();
    } catch (_) {
      _dbFuture = null;
      rethrow;
    }
  }
}
```

## Example

**BAD** — unguarded write in the BLoC, `try/catch` in the store:

```dart
// Store
class DatabaseUrlStore {
  Future<int> insertFolder(Folder folder) async {
    try {
      return (await _dao).insertFolder(folder);
    } catch (e) {
      return -1;
    }
  }
}

// BLoC
class FolderSelectionBloc {
  Future<void> _onSaveFolderClicked(
    OnSaveFolderClicked event,
    Emitter<FolderSelectionState> emit,
  ) async {
    final name = createFolderController.text.trim();
    final id = await urlStore.insertFolder(Folder(folderName: name));
    emit(
      state.copyWith(
        action: CloseWithSelectedFolder(Folder(id: id, folderName: name)),
      ),
    );
  }
}
```

**GOOD** — store lets errors propagate, BLoC handles them:

```dart
// Store
class DatabaseUrlStore {
  Future<int> insertFolder(Folder folder) async =>
      (await _dao).insertFolder(folder);
}

// BLoC
class FolderSelectionBloc {
  Future<void> _onSaveFolderClicked(
    OnSaveFolderClicked event,
    Emitter<FolderSelectionState> emit,
  ) async {
    final name = createFolderController.text.trim();
    try {
      final id = await urlStore.insertFolder(Folder(folderName: name));
      emit(
        state.copyWith(
          action: CloseWithSelectedFolder(Folder(id: id, folderName: name)),
        ),
      );
    } catch (e, st) {
      logError('Failed to create folder', e, stackTrace: st);
      emit(
        state.copyWith(action: const ShowToast('Error While Creating Folder')),
      );
    }
  }
}
```

**GOOD** — stream errors are logged, not swallowed:

```dart
class FolderSelectionBloc {
  Future<void> _onInit(
    OnInitEvent event,
    Emitter<FolderSelectionState> emit,
  ) async {
    await emit.forEach<List<Folder>>(
      urlStore.findAllFolders(),
      onData: (folders) => state.copyWith(isLoading: false),
      onError: (e, st) {
        logError('Failed to load folders', e, stackTrace: st);
        return state.copyWith(isLoading: false);
      },
    );
  }
}
```

## Hive reads

Type-check instead of `try/catch`:

```dart
class AppSettingsService {
  Box get _box => Hive.box(HiveService.settingsBoxName);

  AppTheme get appTheme {
    final value = _box.get(SettingsKeys.appTheme);
    return value is AppTheme ? value : AppDefaults.appTheme;
  }
}
```
