import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:mindful_links/core/data/database/entity/tag.dart';
import 'package:mindful_links/features/add_new_link/bloc/add_new_link_event.dart';
import 'package:mindful_links/features/add_new_link/bloc/add_new_link_state.dart';

class AddNewLinkBloc extends Bloc<AddNewLinkEvent, AddNewLinkState> {
  AddNewLinkBloc() : super(AddNewLinkState.initial()) {
    nameController = TextEditingController();
    urlController = TextEditingController(text: state.url);
    urlFocusNode = FocusNode();

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

  void _onNameChanged(OnNameChanged event, Emitter<AddNewLinkState> emit) {
    if (nameController.text != event.name) {
      nameController.text = event.name;
    }
    emit(state.copyWith(urlName: event.name));
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
    emit(state.copyWith(folder: event.folder));
  }

  void _onTagsSelected(OnTagsSelected event, Emitter<AddNewLinkState> emit) {
    emit(state.copyWith(tags: event.tags));
  }

  void _onTagRemoved(OnTagRemoved event, Emitter<AddNewLinkState> emit) {
    final updatedTags = List<Tag>.from(state.selectedTags)..remove(event.tag);
    emit(state.copyWith(tags: updatedTags));
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
