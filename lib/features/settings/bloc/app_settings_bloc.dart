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
    on<ThemeChanged>(_onThemeChanged);
    on<LanguageChanged>(_onLocalizationChanged);
    on<TrashRetentionChanged>(_onTrashRetentionChanged);
    on<SaveSettingsRequested>(_onSaveSettingsRequested);
    on<ShowLanguageSheetRequested>(_onShowLanguageSheetRequested);
    on<ShowEraseDialogRequested>(_onShowEraseDialogRequested);
    on<EraseAllRequested>(_onEraseAllRequested);
    on<ExportBookmarksRequested>(_onExportBookmarksRequested);
    on<ImportBookmarksRequested>(_onImportBookmarksRequested);
    on<ExportBookmarksConfirmed>(_onExportBookmarksConfirmed);
    on<ImportBookmarksConfirmed>(_onImportBookmarksConfirmed);
    on<ActionHandled>(_onActionHandled);
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

  void _onThemeChanged(ThemeChanged event, Emitter<AppSettingsState> emit) {
    _updateDraft(emit, state.newAppSettings.copyWith(appTheme: event.theme));
  }

  void _onLocalizationChanged(
    LanguageChanged event,
    Emitter<AppSettingsState> emit,
  ) {
    _updateDraft(
      emit,
      state.newAppSettings.copyWith(appLanguage: event.language),
    );
  }

  void _onTrashRetentionChanged(
    TrashRetentionChanged event,
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
    ShowLanguageSheetRequested event,
    Emitter<AppSettingsState> emit,
  ) {
    emit(state.copyWith(action: const ShowLanguageSheet()));
  }

  void _onShowEraseDialogRequested(
    ShowEraseDialogRequested event,
    Emitter<AppSettingsState> emit,
  ) {
    emit(state.copyWith(action: const ShowEraseDialog()));
  }

  Future<void> _onEraseAllRequested(
    EraseAllRequested event,
    Emitter<AppSettingsState> emit,
  ) async {
    try {
      final urlStore = _urlStoreProvider();
      await urlStore.clearAll();
      await urlStore.seedDefaultFolderIfNotExist();
      await urlStore.seedDefaultTagsIfNotExist();
      emit(state.copyWith(action: const ShowToast('Data Erased')));
    } catch (e, st) {
      logError('Failed to erase all data', e, stackTrace: st);
      emit(state.copyWith(action: const ShowToast('Error While Erasing Data')));
    }
  }

  Future<void> _onExportBookmarksRequested(
    ExportBookmarksRequested event,
    Emitter<AppSettingsState> emit,
  ) async {
    try {
      final urls = await _urlStoreProvider().findAllUrl().first;
      emit(state.copyWith(action: ShowExportSheet(count: urls.length)));
    } catch (e, st) {
      logError('Failed to load bookmarks for export', e, stackTrace: st);
      emit(
        state.copyWith(action: const ShowToast('Error While Exporting BookMarks')),
      );
    }
  }

  Future<void> _onImportBookmarksRequested(
    ImportBookmarksRequested event,
    Emitter<AppSettingsState> emit,
  ) async {
    emit(state.copyWith(action: const ShowImportSheet()));
  }

  void _onExportBookmarksConfirmed(
    ExportBookmarksConfirmed event,
    Emitter<AppSettingsState> emit,
  ) {
    emit(state.copyWith(action: const ShowToast('Exported Links')));
  }

  void _onImportBookmarksConfirmed(
    ImportBookmarksConfirmed event,
    Emitter<AppSettingsState> emit,
  ) {
    emit(state.copyWith(action: const ShowToast('Imported Link')));
  }

  void _onActionHandled(ActionHandled event, Emitter<AppSettingsState> emit) {
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
