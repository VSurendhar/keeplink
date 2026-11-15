import 'package:equatable/equatable.dart';
import 'package:mindful_links/features/settings/bloc/app_settings_action.dart';
import 'package:mindful_links/features/settings/bloc/app_settings_bloc.dart';

export 'package:mindful_links/features/settings/bloc/app_settings_action.dart';

final class AppSettingsState extends Equatable {
  const AppSettingsState({
    required this.currentAppSettings,
    required this.newAppSettings,
    this.isSaving = false,
    this.action,
  });

  /// Settings as currently persisted in Hive.
  final AppSettings currentAppSettings;

  /// Draft settings edited by the user and not yet saved.
  final AppSettings newAppSettings;

  final bool isSaving;
  final AppSettingsAction? action;

  bool get hasUnsavedChanges => newAppSettings != currentAppSettings;

  AppSettingsState copyWith({
    AppSettings? currentAppSettings,
    AppSettings? newAppSettings,
    bool? isSaving,
    AppSettingsAction? action,
    bool clearAction = false,
  }) {
    return AppSettingsState(
      currentAppSettings: currentAppSettings ?? this.currentAppSettings,
      newAppSettings: newAppSettings ?? this.newAppSettings,
      isSaving: isSaving ?? this.isSaving,
      action: clearAction ? null : (action ?? this.action),
    );
  }

  @override
  List<Object?> get props => [
    currentAppSettings,
    newAppSettings,
    isSaving,
    action,
  ];

  @override
  String toString() {
    return 'AppSettingsState{currentAppSettings: $currentAppSettings, newAppSettings: $newAppSettings, isSaving: $isSaving, action: $action}';
  }
}
