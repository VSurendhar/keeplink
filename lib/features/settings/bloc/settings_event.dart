import 'package:equatable/equatable.dart';
import 'package:mindful_links/core/data/hive/models/app_settings.dart';

sealed class AppSettingsEvent extends Equatable {
  const AppSettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the user changes the app theme (Light / Dark).
final class AppSettingsThemeChanged extends AppSettingsEvent {
  const AppSettingsThemeChanged(this.theme);

  final AppTheme theme;

  @override
  List<Object?> get props => [theme];
}

/// Triggered when the user changes the app localization / language.
final class AppSettingsLanguageChanged extends AppSettingsEvent {
  const AppSettingsLanguageChanged(this.language);

  final AppLanguage language;

  @override
  List<Object?> get props => [language];
}

/// Triggered when the user changes the auto-delete trash retention period.
final class AppSettingsTrashRetentionChanged extends AppSettingsEvent {
  const AppSettingsTrashRetentionChanged(this.retentionPeriod);

  final int retentionPeriod;

  @override
  List<Object?> get props => [retentionPeriod];
}

/// Triggered when the user requests to open language selection sheet.
final class AppSettingsShowLanguageSheetRequested extends AppSettingsEvent {
  const AppSettingsShowLanguageSheetRequested();
}

/// Triggered when the user requests to open erase confirmation dialog.
final class AppSettingsShowEraseDialogRequested extends AppSettingsEvent {
  const AppSettingsShowEraseDialogRequested();
}

/// Triggered when the user requests to erase all data.
final class AppSettingsEraseAllRequested extends AppSettingsEvent {
  const AppSettingsEraseAllRequested();
}

/// Triggered when the user requests to export bookmarks.
final class AppSettingsExportBookmarksRequested extends AppSettingsEvent {
  const AppSettingsExportBookmarksRequested();
}

/// Triggered when the user requests to import bookmarks.
final class AppSettingsImportBookmarksRequested extends AppSettingsEvent {
  const AppSettingsImportBookmarksRequested();
}

/// Triggered when a one-shot UI action has been consumed/handled by the view.
final class AppSettingsActionHandled extends AppSettingsEvent {
  const AppSettingsActionHandled();
}
