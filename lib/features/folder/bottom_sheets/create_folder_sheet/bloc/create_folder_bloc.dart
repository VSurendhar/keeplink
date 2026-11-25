import 'package:bloc/bloc.dart';
import 'package:keep_links/core/data/database/entity/folder.dart';
import 'package:keep_links/core/data/database/url_store.dart';
import 'package:keep_links/core/utils/folder_name_validator.dart';
import 'package:keep_links/features/folder/bottom_sheets/create_folder_sheet/bloc/create_folder_event.dart';
import 'package:keep_links/features/folder/bottom_sheets/create_folder_sheet/bloc/create_folder_state.dart';
import 'package:keep_links/features/logger/logger.dart';

class CreateFolderBloc extends Bloc<CreateFolderEvent, CreateFolderState> {
  CreateFolderBloc({required UrlStore urlStore})
    : _urlStore = urlStore,
      super(const CreateFolderState()) {
    on<OnNameChanged>(_onNameChanged);
    on<OnCreateClicked>(_onCreateClicked);
    on<OnActionHandled>(_onActionHandled);
  }

  final UrlStore _urlStore;

  void _onNameChanged(OnNameChanged event, Emitter<CreateFolderState> emit) {
    emit(state.copyWith(name: event.name));
  }

  Future<void> _onCreateClicked(
    OnCreateClicked event,
    Emitter<CreateFolderState> emit,
  ) async {
    if (!state.isCreateEnabled) return;
    final name = state.name.trim();
    final nameError = FolderNameValidator.validate(name);
    if (nameError != null) {
      emit(state.copyWith(action: ShowToast(nameError)));
      return;
    }

    emit(state.copyWith(isCreating: true));
    try {
      if (await _urlStore.findFolderByName(name) != null) {
        emit(state.copyWith(action: const ShowToast('Folder already exists')));
        return;
      }
      await _urlStore.insertFolder(Folder(folderName: name));
      emit(state.copyWith(action: CloseWithMessage('$name created')));
    } catch (e, st) {
      logError('Failed to create folder', e, stackTrace: st);
      emit(
        state.copyWith(action: const ShowToast('Error While Creating Folder')),
      );
    } finally {
      emit(state.copyWith(isCreating: false));
    }
  }

  void _onActionHandled(
    OnActionHandled event,
    Emitter<CreateFolderState> emit,
  ) {
    emit(state.copyWith(clearAction: true));
  }
}
