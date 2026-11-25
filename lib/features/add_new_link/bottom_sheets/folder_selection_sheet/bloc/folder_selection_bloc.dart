import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:keep_links/core/utils/app_defaults.dart';
import 'package:keep_links/core/data/database/entity/folder.dart';
import 'package:keep_links/core/data/database/url_store.dart';
import 'package:keep_links/features/add_new_link/bottom_sheets/folder_selection_sheet/bloc/folder_selection_event.dart';
import 'package:keep_links/features/add_new_link/bottom_sheets/folder_selection_sheet/bloc/folder_selection_state.dart';
import 'package:keep_links/features/logger/logger.dart';

class FolderSelectionBloc
    extends Bloc<FolderSelectionEvent, FolderSelectionState> {
  FolderSelectionBloc({
    required this.urlStore,
    required Folder initialSelectedFolder,
  }) : super(FolderSelectionState.initial(initialSelectedFolder)) {
    createFolderController = TextEditingController();
    createFolderFocusNode = FocusNode();

    on<OnInitEvent>(_onInit);
    on<OnToggleCreateMode>(_onToggleCreateMode);
    on<OnSaveFolderClicked>(_onSaveFolderClicked);
    on<OnDeleteFolderClicked>(_onDeleteFolderClicked);
    on<OnActionHandled>(_onActionHandled);
  }

  final UrlStore urlStore;
  late final TextEditingController createFolderController;
  late final FocusNode createFolderFocusNode;

  /// Link count per folder id. Refreshed after a delete moves links, and
  /// read whenever the folder stream emits.
  Map<int, int> _urlCountByFolderId = const {};

  @override
  Future<void> close() {
    createFolderController.dispose();
    createFolderFocusNode.dispose();
    return super.close();
  }

  /// Whether [folder] is the default folder, which can't be deleted.
  bool isDefaultFolder(Folder folder) => AppDefaults.isDefaultFolder(folder);

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
    createFolderFocusNode.unfocus();
    final name = createFolderController.text.trim();
    if (name.isEmpty || name.length > 40) {
      emit(
        state.copyWith(
          action: const ShowToast(
            'Folder name must be between 1 and 40 characters',
          ),
        ),
      );
      return;
    }

    final alreadyExists = state.folders.any(
      (item) => item.folder.folderName.trim() == name,
    );
    if (alreadyExists) {
      emit(state.copyWith(action: ShowToast('Folder already exists')));
      return;
    }

    try {
      final id = await urlStore.insertFolder(Folder(folderName: name));
      createFolderController.clear();
      emit(
        state.copyWith(
          isCreating: false,
          action: CloseWithSelectedFolder(Folder(id: id, folderName: name)),
        ),
      );
    } catch (e, st) {
      logError('Failed to create folder', e, stackTrace: st);
      emit(
        state.copyWith(action: const ShowToast('Error While Creating Folder')),
      );
    }
  }

  /// Deletes the folder and moves its saved links into the default folder.
  ///
  /// If the deleted folder was the selected one, the sheet closes with the
  /// default folder selected, so the Add Link page never keeps a deleted
  /// folder.
  Future<void> _onDeleteFolderClicked(
    OnDeleteFolderClicked event,
    Emitter<FolderSelectionState> emit,
  ) async {
    createFolderFocusNode.unfocus();
    final folder = event.folder;
    final folderId = folder.id;
    if (folderId == null || isDefaultFolder(folder)) return;

    final defaultFolder = state.folders
        .map((item) => item.folder)
        .where(isDefaultFolder)
        .firstOrNull;
    final defaultFolderId = defaultFolder?.id;
    if (defaultFolder == null || defaultFolderId == null) {
      logError(
        'Failed to delete folder ${folder.folderName}: default folder not found',
        null,
      );
      emit(state.copyWith(action: const ShowToast('Default Folder not found')));
      return;
    }

    try {
      await urlStore.deleteFolderAndMoveUrls(
        sourceFolderId: folderId,
        targetFolderId: defaultFolderId,
      );
    } catch (e, st) {
      logError('Failed to delete folder', e, stackTrace: st);
      emit(
        state.copyWith(action: const ShowToast('Error While Deleting Folder')),
      );
      return;
    }

    final message = '${folder.folderName} deleted';
    if (state.selectedFolder.id == folderId) {
      emit(
        state.copyWith(
          action: CloseWithSelectedFolder(defaultFolder, message: message),
        ),
      );
      return;
    }

    // Moved links change the default folder's count.
    _urlCountByFolderId = await _loadUrlCounts();
    final remainingFolders = state.folders
        .map((item) => item.folder)
        .where((item) => item.id != folderId);
    emit(
      state.copyWith(
        folders: _buildFolderItems(remainingFolders),
        action: ShowToast(message),
      ),
    );
  }

  void _onActionHandled(
    OnActionHandled event,
    Emitter<FolderSelectionState> emit,
  ) {
    emit(state.copyWith(clearAction: true));
  }

  /// Returns the loaded folder that matches the current selection.
  ///
  /// The selection passed in can be a folder without an `id`, such as the
  /// default `Folder(folderName: 'Defaults')` from `AppDefaults`. The sheet
  /// highlights a folder only when both `id` and name match, so the selection
  /// is swapped for the loaded database copy (matched by `id` or name). That
  /// way it is highlighted, and the folder returned to the Add Link page has
  /// its `id`. If no loaded folder matches, the selection is kept as it is.
  Folder _matchSelectedFolder(List<FolderItem> items) {
    final currentSelection = state.selectedFolder;
    final match = items.where(
      (item) =>
          item.folder.id == currentSelection.id ||
          item.folder.folderName == currentSelection.folderName,
    );
    return match.firstOrNull?.folder ?? currentSelection;
  }

  /// Link counts per folder id, or an empty map (all counts 0) on failure.
  Future<Map<int, int>> _loadUrlCounts() async {
    try {
      return await urlStore.findUrlCountPerFolder();
    } catch (e, st) {
      logError(
        'Failed to load folder link counts',
        e,
        stackTrace: st,
        isShowToastInDebug: true,
      );
      return const {};
    }
  }

  List<FolderItem> _buildFolderItems(Iterable<Folder> folders) {
    return folders.map((folder) {
      final id = folder.id;
      final linkCount = id == null ? 0 : (_urlCountByFolderId[id] ?? 0);
      return FolderItem(folder: folder, linkCount: linkCount);
    }).toList();
  }

  Future<void> _onInit(
    OnInitEvent event,
    Emitter<FolderSelectionState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    _urlCountByFolderId = await _loadUrlCounts();

    await emit.forEach<List<Folder>>(
      urlStore.findAllFolders(),
      onData: (folders) {
        final items = _buildFolderItems(folders);
        return state.copyWith(
          isLoading: false,
          folders: items,
          selectedFolder: _matchSelectedFolder(items),
        );
      },
      onError: (e, st) {
        logError(
          'Failed to load folders',
          e,
          stackTrace: st,
          isShowToastInDebug: true,
        );
        return state.copyWith(isLoading: false);
      },
    );
  }
}

class FolderItem extends Equatable {
  const FolderItem({required this.folder, required this.linkCount});

  final Folder folder;
  final int linkCount;

  @override
  List<Object?> get props => [folder.id, folder.folderName, linkCount];
}
