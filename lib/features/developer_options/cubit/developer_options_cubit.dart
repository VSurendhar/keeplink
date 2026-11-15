import 'package:bloc/bloc.dart';
import 'package:mindful_links/core/data/database/url_store.dart';
import 'package:mindful_links/features/developer_options/cubit/developer_options_state.dart';
import 'package:mindful_links/features/developer_options/service/developer_options_service.dart';
import 'package:mindful_links/features/logger/logger.dart';

class DeveloperOptionsCubit extends Cubit<DeveloperOptionsState> {
  DeveloperOptionsCubit({
    required DeveloperOptionsService developerOptionsService,
    required UrlStore Function() urlStoreProvider,
  }) : _developerOptionsService = developerOptionsService,
       _urlStoreProvider = urlStoreProvider,
       super(DeveloperOptionsState(isMockStore: UrlStoreSwitcher.isMock));

  final DeveloperOptionsService _developerOptionsService;

  /// Resolved on every use so the store picked by [setMockStore] is used.
  final UrlStore Function() _urlStoreProvider;

  void setMockStore(bool useMock) {
    if (useMock) {
      UrlStoreSwitcher.useMock();
    } else {
      UrlStoreSwitcher.useReal();
    }
    emit(
      state.copyWith(
        isMockStore: UrlStoreSwitcher.isMock,
        action: ShowToast(
          useMock
              ? 'Switched to Mock URL Store'
              : 'Switched to Database URL Store',
        ),
      ),
    );
  }

  /// Seeds initial database records, then prints the database state.
  Future<void> initialDatabaseSetup() async {
    final urlStore = _urlStoreProvider();
    try {
      await _developerOptionsService.seedDatabase(urlStore);
      emit(
        state.copyWith(action: const ShowToast('Database seeded successfully')),
      );
    } catch (e, st) {
      logError(
        'Something wrong happened while creating Seed database',
        e,
        stackTrace: st,
      );
      emit(
        state.copyWith(
          action: ShowToast(
            'Something wrong happened while creating Seed database: $e',
          ),
        ),
      );
    }
    await _printDatabase(urlStore);
  }

  Future<void> initialAppSettings() async {
    try {
      await _developerOptionsService.initialAppSettings();
      emit(state.copyWith(action: const ShowToast('App settings initialized')));
    } catch (e, st) {
      logError('Failed to initialize app settings', e, stackTrace: st);
      emit(
        state.copyWith(
          action: const ShowToast('Error While Initializing App Settings'),
        ),
      );
    }
  }

  void actionHandled() => emit(state.copyWith(clearAction: true));

  /// Debug-console output only, so failures are logged without a toast.
  Future<void> _printDatabase(UrlStore urlStore) async {
    try {
      await _developerOptionsService.printDatabase(urlStore);
    } catch (e, st) {
      logError('Failed to print database', e, stackTrace: st);
    }
  }
}
