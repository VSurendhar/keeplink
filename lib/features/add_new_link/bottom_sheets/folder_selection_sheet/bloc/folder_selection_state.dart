import 'package:equatable/equatable.dart';
import 'package:keep_links/core/data/database/entity/folder.dart';
import 'package:keep_links/features/add_new_link/bottom_sheets/folder_selection_sheet/bloc/folder_selection_action.dart';
import 'package:keep_links/features/add_new_link/bottom_sheets/folder_selection_sheet/bloc/folder_selection_bloc.dart';

export 'package:keep_links/features/add_new_link/bottom_sheets/folder_selection_sheet/bloc/folder_selection_action.dart';

final class FolderSelectionState extends Equatable {
  const FolderSelectionState({
    this.isLoading = true,
    this.folders = const [],
    required this.selectedFolder,
    this.isCreating = false,
    this.isSaving = false,
    this.action,
  });

  final bool isLoading;
  final List<FolderItem> folders;
  final Folder selectedFolder;

  /// Whether the create folder input is open.
  final bool isCreating;

  /// Whether a new folder is being saved.
  final bool isSaving;
  final FolderSelectionAction? action;

  factory FolderSelectionState.initial(Folder initialSelectedFolder) {
    return FolderSelectionState(
      isLoading: true,
      folders: const [],
      selectedFolder: initialSelectedFolder,
      isCreating: false,
    );
  }

  FolderSelectionState copyWith({
    bool? isLoading,
    List<FolderItem>? folders,
    Folder? selectedFolder,
    bool? isCreating,
    bool? isSaving,
    FolderSelectionAction? action,
    bool clearAction = false,
  }) {
    return FolderSelectionState(
      isLoading: isLoading ?? this.isLoading,
      folders: folders ?? this.folders,
      selectedFolder: selectedFolder ?? this.selectedFolder,
      isCreating: isCreating ?? this.isCreating,
      isSaving: isSaving ?? this.isSaving,
      action: clearAction ? null : (action ?? this.action),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    folders,
    selectedFolder,
    isCreating,
    isSaving,
    action,
  ];

  @override
  String toString() {
    return 'FolderSelectionState{isLoading: $isLoading, folders: $folders, selectedFolder: $selectedFolder, isCreating: $isCreating, isSaving: $isSaving, action: $action}';
  }
}
