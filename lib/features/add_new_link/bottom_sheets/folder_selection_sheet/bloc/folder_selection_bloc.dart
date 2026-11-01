import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mindful_links/core/data/database/entity/folder.dart';
import 'package:mindful_links/core/data/database/url_store.dart';
import 'package:mindful_links/features/add_new_link/bottom_sheets/folder_selection_sheet/bloc/folder_selection_event.dart';
import 'package:mindful_links/features/add_new_link/bottom_sheets/folder_selection_sheet/bloc/folder_selection_state.dart';

class FolderItem extends Equatable {
  const FolderItem({required this.folder, required this.linkCount});

  final Folder folder;
  final int linkCount;

  @override
  List<Object?> get props => [folder.id, folder.folderName, linkCount];
}

class FolderSelectionBloc
    extends Bloc<FolderSelectionEvent, FolderSelectionState> {
  FolderSelectionBloc({required this.urlStore, Folder? initialSelectedFolder})
    : super(FolderSelectionState.initial(initialSelectedFolder)) {
    createFolderController = TextEditingController();
    createFolderFocusNode = FocusNode();

    on<OnInitEvent>(_onInit);
    on<OnToggleCreateMode>(_onToggleCreateMode);
    on<OnSaveFolderClicked>(_onSaveFolderClicked);
  }

  final UrlStore urlStore;
  late final TextEditingController createFolderController;
  late final FocusNode createFolderFocusNode;

  @override
  Future<void> close() {
    createFolderController.dispose();
    createFolderFocusNode.dispose();
    return super.close();
  }

  void _onToggleCreateMode(
    OnToggleCreateMode event,
    Emitter<FolderSelectionState> emit,
  ) {
    final isCreating = !state.isCreating;
    if (isCreating) {
      createFolderFocusNode.requestFocus();
    } else {
      createFolderFocusNode.unfocus();
    }
    emit(state.copyWith(isCreating: isCreating));
  }

  Future<void> _onSaveFolderClicked(
    OnSaveFolderClicked event,
    Emitter<FolderSelectionState> emit,
  ) async {
    final name = createFolderController.text.trim();
    createFolderFocusNode.unfocus();
    if (name.isEmpty) return;

    final newFolder = Folder(folderName: name);
    await urlStore.insertFolder(newFolder);
    createFolderController.clear();
    emit(state.copyWith(isCreating: false));
  }

  Future<void> _onInit(
    OnInitEvent event,
    Emitter<FolderSelectionState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    await emit.forEach<List<Folder>>(
      urlStore.findAllFolders(),
      onData: (folders) {
        final random = Random();
        final items = folders
            .map(
              (f) => FolderItem(folder: f, linkCount: 1 + random.nextInt(10)),
            )
            .toList();

        final currentSelection = state.selectedFolder;
        Folder? matchedSelection = currentSelection;
        if (currentSelection != null) {
          final found = items.where(
            (i) =>
                i.folder.id == currentSelection.id ||
                i.folder.folderName == currentSelection.folderName,
          );
          if (found.isNotEmpty) {
            matchedSelection = found.first.folder;
          }
        } else if (items.isNotEmpty) {
          matchedSelection = items.first.folder;
        }

        return state.copyWith(
          isLoading: false,
          folders: items,
          selectedFolder: matchedSelection,
        );
      },
      onError: (_, __) => state.copyWith(isLoading: false),
    );
  }
}
