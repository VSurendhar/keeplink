import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mindful_links/core/data/database/url_store.dart';
import 'package:mindful_links/core/data/hive/models/app_settings.dart';
import 'package:mindful_links/features/logger/logger.dart';
import 'package:mindful_links/features/settings/bloc/app_settings_event.dart';
import 'package:mindful_links/features/settings/bloc/app_settings_state.dart';
import 'package:mindful_links/features/settings/service/app_settings_service.dart';

class AppSettingsBloc extends Bloc<AppSettingsEvent, AppSettingsState> {
  AppSettingsBloc({
    required AppSettingsService appSettingsService,
    required UrlStore Function() urlStoreProvider,
  }) : _urlStoreProvider = urlStoreProvider,
       _appSettingsService = appSettingsService,
       super(_initialState(appSettingsService)) {
    on<AppSettingsThemeChanged>(_onThemeChanged);
    on<AppSettingsLanguageChanged>(_onLocalizationChanged);
    on<AppSettingsTrashRetentionChanged>(_onTrashRetentionChanged);
    on<SaveSettingsRequested>(_onSaveSettingsRequested);
    on<AppSettingsShowLanguageSheetRequested>(_onShowLanguageSheetRequested);
    on<AppSettingsShowEraseDialogRequested>(_onShowEraseDialogRequested);
    on<AppSettingsEraseAllRequested>(_onEraseAllRequested);
    on<AppSettingsExportBookmarksRequested>(_onExportBookmarksRequested);
    on<AppSettingsImportBookmarksRequested>(_onImportBookmarksRequested);
    on<AppSettingsActionHandled>(_onActionHandled);
  }

  final AppSettingsService _appSettingsService;

  /// On every use so a mock/real switch in Developer Options is
  /// picked up even though this BLoC outlives the switch (IndexedStack).
  final UrlStore Function() _urlStoreProvider;

  static AppSettingsState _initialState(AppSettingsService service) {
    final persisted = AppSettings(
      appTheme: service.appTheme,
      appLanguage: service.appLanguage,
      retentionPeriod: service.trashRetention,
    );
    return AppSettingsState(
      currentAppSettings: persisted,
      newAppSettings: persisted,
    );
  }

  void _onThemeChanged(
    AppSettingsThemeChanged event,
    Emitter<AppSettingsState> emit,
  ) {
    _updateDraft(emit, state.newAppSettings.copyWith(appTheme: event.theme));
  }

  void _onLocalizationChanged(
    AppSettingsLanguageChanged event,
    Emitter<AppSettingsState> emit,
  ) {
    _updateDraft(
      emit,
      state.newAppSettings.copyWith(appLanguage: event.language),
    );
  }

  void _onTrashRetentionChanged(
    AppSettingsTrashRetentionChanged event,
    Emitter<AppSettingsState> emit,
  ) {
    _updateDraft(
      emit,
      state.newAppSettings.copyWith(retentionPeriod: event.retentionPeriod),
    );
  }

  void _updateDraft(Emitter<AppSettingsState> emit, AppSettings draft) {
    emit(state.copyWith(newAppSettings: draft));
  }

  Future<void> _onSaveSettingsRequested(
    SaveSettingsRequested event,
    Emitter<AppSettingsState> emit,
  ) async {
    if (state.isSaving || !state.hasUnsavedChanges) return;

    final draft = state.newAppSettings;
    emit(state.copyWith(isSaving: true));
    try {
      await _appSettingsService.saveAppTheme(draft.appTheme);
      await _appSettingsService.saveLanguage(draft.appLanguage);
      await _appSettingsService.saveTrashRetention(draft.retentionPeriod);
      emit(
        state.copyWith(
          currentAppSettings: draft,
          isSaving: false,
          action: const ShowToast('Settings Saved'),
        ),
      );
    } catch (e, st) {
      logError('Failed to save app settings', e, stackTrace: st);
      emit(
        state.copyWith(
          isSaving: false,
          action: const ShowToast('Error While Saving Settings'),
        ),
      );
    }
  }

  void _onShowLanguageSheetRequested(
    AppSettingsShowLanguageSheetRequested event,
    Emitter<AppSettingsState> emit,
  ) {
    emit(state.copyWith(action: const AppSettingsShowLanguageSheetAction()));
  }

  void _onShowEraseDialogRequested(
    AppSettingsShowEraseDialogRequested event,
    Emitter<AppSettingsState> emit,
  ) {
    emit(state.copyWith(action: const AppSettingsShowEraseDialogAction()));
  }

  Future<void> _onEraseAllRequested(
    AppSettingsEraseAllRequested event,
    Emitter<AppSettingsState> emit,
  ) async {
    final urlStore = _urlStoreProvider();
    await urlStore.clearAll();
    await urlStore.seedDefaultFolderIfNotExist();
    await urlStore.seedDefaultTagsIfNotExist();
  }

  Future<void> _onExportBookmarksRequested(
    AppSettingsExportBookmarksRequested event,
    Emitter<AppSettingsState> emit,
  ) async {
    final urls = await _urlStoreProvider().findAllUrl().first;
    emit(
      state.copyWith(
        action: AppSettingsShowExportSheetAction(count: urls.length),
      ),
    );
  }

  Future<void> _onImportBookmarksRequested(
    AppSettingsImportBookmarksRequested event,
    Emitter<AppSettingsState> emit,
  ) async {
    emit(state.copyWith(action: const AppSettingsShowImportSheetAction()));
  }

  void _onActionHandled(
    AppSettingsActionHandled event,
    Emitter<AppSettingsState> emit,
  ) {
    emit(state.copyWith(clearAction: true));
  }
}

/// The user-editable app settings, grouped so they can be compared and saved
/// together.
class AppSettings extends Equatable {
  const AppSettings({
    required this.appTheme,
    required this.appLanguage,
    required this.retentionPeriod,
  });

  final AppTheme appTheme;
  final AppLanguage appLanguage;
  final int retentionPeriod;

  AppSettings copyWith({
    AppTheme? appTheme,
    AppLanguage? appLanguage,
    int? retentionPeriod,
  }) {
    return AppSettings(
      appTheme: appTheme ?? this.appTheme,
      appLanguage: appLanguage ?? this.appLanguage,
      retentionPeriod: retentionPeriod ?? this.retentionPeriod,
    );
  }

  @override
  List<Object?> get props => [appTheme, appLanguage, retentionPeriod];

  @override
  String toString() {
    return 'AppSettings{appTheme: $appTheme, appLanguage: $appLanguage, retentionPeriod: $retentionPeriod}';
  }
}
