import 'package:bloc/bloc.dart';
import 'package:mindful_links/core/data/database/url_store.dart';
import 'package:mindful_links/features/settings/bloc/app_settings_event.dart';
import 'package:mindful_links/features/settings/bloc/app_settings_state.dart';
import 'package:mindful_links/features/settings/service/settings_service.dart';

class AppSettingsBloc extends Bloc<AppSettingsEvent, AppSettingsState> {
  AppSettingsBloc({
    required SettingsService appSettingsService,
    required UrlStore urlStore,
  }) : _urlStore = urlStore,
       _appSettingsService = appSettingsService,
       super(
         AppSettingsState(
           appTheme: appSettingsService.appTheme,
           appLanguage: appSettingsService.appLanguage,
           retentionPeriod: appSettingsService.trashRetention,
         ),
       ) {
    on<AppSettingsThemeChanged>(_onThemeChanged);
    on<AppSettingsLanguageChanged>(_onLocalizationChanged);
    on<AppSettingsTrashRetentionChanged>(_onTrashRetentionChanged);
    on<AppSettingsShowLanguageSheetRequested>(_onShowLanguageSheetRequested);
    on<AppSettingsShowEraseDialogRequested>(_onShowEraseDialogRequested);
    on<AppSettingsEraseAllRequested>(_onEraseAllRequested);
    on<AppSettingsExportBookmarksRequested>(_onExportBookmarksRequested);
    on<AppSettingsImportBookmarksRequested>(_onImportBookmarksRequested);
    on<AppSettingsActionHandled>(_onActionHandled);
  }

  final SettingsService _appSettingsService;
  final UrlStore _urlStore;

  Future<void> _onThemeChanged(
    AppSettingsThemeChanged event,
    Emitter<AppSettingsState> emit,
  ) async {
    emit(state.copyWith(appTheme: event.theme));
    await _appSettingsService.saveAppTheme(event.theme);
  }

  Future<void> _onLocalizationChanged(
    AppSettingsLanguageChanged event,
    Emitter<AppSettingsState> emit,
  ) async {
    emit(state.copyWith(appLanguage: event.language));
    await _appSettingsService.saveLanguage(event.language);
  }

  Future<void> _onTrashRetentionChanged(
    AppSettingsTrashRetentionChanged event,
    Emitter<AppSettingsState> emit,
  ) async {
    emit(state.copyWith(retentionPeriod: event.retentionPeriod));
    await _appSettingsService.saveTrashRetention(event.retentionPeriod.round());
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
    await _urlStore.clearAll();
  }

  Future<void> _onExportBookmarksRequested(
    AppSettingsExportBookmarksRequested event,
    Emitter<AppSettingsState> emit,
  ) async {
    final urls = await _urlStore.findAllUrl().first;
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
