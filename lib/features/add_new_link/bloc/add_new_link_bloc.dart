import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:mindful_links/core/app_defaults.dart';
import 'package:mindful_links/core/data/database/entity/tag.dart';
import 'package:mindful_links/core/data/database/url_store.dart';
import 'package:mindful_links/features/add_new_link/bloc/add_new_link_event.dart';
import 'package:mindful_links/features/add_new_link/bloc/add_new_link_state.dart';
import 'package:mindful_links/features/logger/logger.dart';

class AddNewLinkBloc extends Bloc<AddNewLinkEvent, AddNewLinkState> {
  AddNewLinkBloc({required this.urlStore}) : super(AddNewLinkState.initial()) {
    nameController = TextEditingController();
    urlController = TextEditingController(text: state.url);
    urlFocusNode = FocusNode();

    on<OnInitEvent>(_onInit);
    on<OnNameChanged>(_onNameChanged);
    on<OnUrlChanged>(_onUrlChanged);
    on<OnShowFolderSheetRequested>(_onShowFolderSheetRequested);
    on<OnShowTagSheetRequested>(_onShowTagSheetRequested);
    on<OnFolderSelected>(_onFolderSelected);
    on<OnTagsSelected>(_onTagsSelected);
    on<OnTagRemoved>(_onTagRemoved);
    on<OnSaveClicked>(_onSaveClicked);
    on<OnActionHandled>(_onActionHandled);
  }

  final UrlStore urlStore;
  late final TextEditingController nameController;
  late final TextEditingController urlController;
  late final FocusNode urlFocusNode;

  @override
  Future<void> close() {
    nameController.dispose();
    urlController.dispose();
    urlFocusNode.dispose();
    return super.close();
  }

  /// Swaps the initial `AppDefaults` folder, which has no id, for its
  /// database copy, so a link saved without opening the folder sheet still
  /// has a folder id for `UrlStore.createUrl`.
  Future<void> _onInit(OnInitEvent event, Emitter<AddNewLinkState> emit) async {
    final defaultFolderName = state.selectedFolder.folderName;
    try {
      final defaultFolder = await urlStore.findFolderByName(defaultFolderName);
      if (defaultFolder == null) {
        logError(
          'Default folder "$defaultFolderName" not found',
          null,
          isShowToastInDebug: true,
        );
        return;
      }
      // Keep a folder the user picked while the lookup was running.
      if (state.selectedFolder.id == null) {
        emit(state.copyWith(selectedFolder: defaultFolder));
      }
    } catch (e, st) {
      logError(
        'Failed to load default folder',
        e,
        stackTrace: st,
        isShowToastInDebug: true,
      );
    }
  }

  void _onNameChanged(OnNameChanged event, Emitter<AddNewLinkState> emit) {
    final characters = event.name.characters;
    final name = characters.length > AppDefaults.linkNameMaxLength
        ? characters.take(AppDefaults.linkNameMaxLength).toString()
        : event.name;
    if (nameController.text != name) {
      nameController.value = TextEditingValue(
        text: name,
        selection: TextSelection.collapsed(offset: name.length),
      );
    }
    emit(state.copyWith(urlName: name));
  }

  void _onUrlChanged(OnUrlChanged event, Emitter<AddNewLinkState> emit) {
    if (urlController.text != event.url) {
      urlController.text = event.url;
    }
    emit(state.copyWith(url: event.url));
  }

  void _onShowFolderSheetRequested(
    OnShowFolderSheetRequested event,
    Emitter<AddNewLinkState> emit,
  ) {
    emit(state.copyWith(action: const ShowFolderSelectionSheetAction()));
  }

  void _onShowTagSheetRequested(
    OnShowTagSheetRequested event,
    Emitter<AddNewLinkState> emit,
  ) {
    emit(state.copyWith(action: const ShowTagSelectionSheetAction()));
  }

  void _onFolderSelected(
    OnFolderSelected event,
    Emitter<AddNewLinkState> emit,
  ) {
    emit(state.copyWith(selectedFolder: event.folder));
  }

  void _onTagsSelected(OnTagsSelected event, Emitter<AddNewLinkState> emit) {
    emit(state.copyWith(selectedTags: event.tags));
  }

  void _onTagRemoved(OnTagRemoved event, Emitter<AddNewLinkState> emit) {
    final updatedTags = List<Tag>.from(state.selectedTags)..remove(event.tag);
    emit(state.copyWith(selectedTags: updatedTags));
  }

  Future<void> _onSaveClicked(
    OnSaveClicked event,
    Emitter<AddNewLinkState> emit,
  ) async {
    // Will be connected to urlStore persistence once bottom sheets and saving flow are aligned.
  }

  void _onActionHandled(OnActionHandled event, Emitter<AddNewLinkState> emit) {
    emit(state.copyWith(clearAction: true));
  }
}
