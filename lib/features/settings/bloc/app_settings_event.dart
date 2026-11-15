import 'package:equatable/equatable.dart';
import 'package:mindful_links/core/data/hive/models/app_settings.dart';

sealed class AppSettingsEvent extends Equatable {
  const AppSettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the user changes the app theme (Light / Dark).
final class ThemeChanged extends AppSettingsEvent {
  const ThemeChanged(this.theme);

  final AppTheme theme;

  @override
  List<Object?> get props => [theme];
}

/// Triggered when the user changes the app localization / language.
final class LanguageChanged extends AppSettingsEvent {
  const LanguageChanged(this.language);

  final AppLanguage language;

  @override
  List<Object?> get props => [language];
}

/// Triggered when the user changes the auto-delete trash retention period.
final class TrashRetentionChanged extends AppSettingsEvent {
  const TrashRetentionChanged(this.retentionPeriod);

  final int retentionPeriod;

  @override
  List<Object?> get props => [retentionPeriod];
}

/// Triggered when the user taps Save to persist the draft settings.
final class SaveSettingsRequested extends AppSettingsEvent {
  const SaveSettingsRequested();
}

/// Triggered when the user requests to open language selection sheet.
final class ShowLanguageSheetRequested extends AppSettingsEvent {
  const ShowLanguageSheetRequested();
}

/// Triggered when the user requests to open erase confirmation dialog.
final class ShowEraseDialogRequested extends AppSettingsEvent {
  const ShowEraseDialogRequested();
}

/// Triggered when the user requests to erase all data.
final class EraseAllRequested extends AppSettingsEvent {
  const EraseAllRequested();
}

/// Triggered when the user requests to export bookmarks.
final class ExportBookmarksRequested extends AppSettingsEvent {
  const ExportBookmarksRequested();
}

/// Triggered when the user confirms the export in the export sheet.
final class ExportBookmarksConfirmed extends AppSettingsEvent {
  const ExportBookmarksConfirmed();
}

/// Triggered when the user requests to import bookmarks.
final class ImportBookmarksRequested extends AppSettingsEvent {
  const ImportBookmarksRequested();
}

/// Triggered when the user confirms the import in the import sheet.
final class ImportBookmarksConfirmed extends AppSettingsEvent {
  const ImportBookmarksConfirmed();
}

/// Triggered when a one-shot UI action has been consumed/handled by the view.
final class ActionHandled extends AppSettingsEvent {
  const ActionHandled();
}
