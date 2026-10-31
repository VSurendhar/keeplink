import 'package:equatable/equatable.dart';
import 'package:mindful_links/core/data/database/entity/folder.dart';
import 'package:mindful_links/features/add_new_link/bottom_sheets/folder_selection_sheet/bloc/folder_selection_bloc.dart';

final class FolderSelectionState extends Equatable {
  const FolderSelectionState({
    this.isLoading = true,
    this.folders = const [],
    this.selectedFolder,
  });

  final bool isLoading;
  final List<FolderItem> folders;
  final Folder? selectedFolder;

  factory FolderSelectionState.initial(Folder? initialSelectedFolder) {
    return FolderSelectionState(
      isLoading: true,
      folders: const [],
      selectedFolder: initialSelectedFolder,
    );
  }

  FolderSelectionState copyWith({
    bool? isLoading,
    List<FolderItem>? folders,
    Folder? selectedFolder,
  }) {
    return FolderSelectionState(
      isLoading: isLoading ?? this.isLoading,
      folders: folders ?? this.folders,
      selectedFolder: selectedFolder ?? this.selectedFolder,
    );
  }

  @override
  List<Object?> get props => [isLoading, folders, selectedFolder];

  @override
  String toString() {
    return 'FolderSelectionState{isLoading: $isLoading, folders: $folders, selectedFolder: $selectedFolder}';
  }
}
