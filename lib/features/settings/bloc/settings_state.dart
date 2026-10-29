import 'package:equatable/equatable.dart';
import 'package:mindful_links/core/data/hive/models/app_settings.dart';
import 'package:mindful_links/features/settings/bloc/settings_action.dart';

export 'package:mindful_links/features/settings/bloc/settings_action.dart';

final class AppSettingsState extends Equatable {
  const AppSettingsState({
    required this.appTheme,
    required this.appLanguage,
    required this.retentionPeriod,
    this.action,
  });

  final AppTheme appTheme;
  final AppLanguage appLanguage;
  final int retentionPeriod;
  final AppSettingsAction? action;

  AppSettingsState copyWith({
    AppTheme? appTheme,
    AppLanguage? appLanguage,
    int? retentionPeriod,
    AppSettingsAction? action,
    bool clearAction = false,
  }) {
    return AppSettingsState(
      appTheme: appTheme ?? this.appTheme,
      appLanguage: appLanguage ?? this.appLanguage,
      retentionPeriod: retentionPeriod ?? this.retentionPeriod,
      action: clearAction ? null : (action ?? this.action),
    );
  }

  @override
  List<Object?> get props => [appTheme, appLanguage, retentionPeriod, action];
}
