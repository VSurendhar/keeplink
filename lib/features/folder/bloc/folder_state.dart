import 'package:equatable/equatable.dart';
import 'package:keep_links/core/data/database/entity/folder.dart';
import 'package:keep_links/features/folder/bloc/folder_action.dart';

export 'package:keep_links/features/folder/bloc/folder_action.dart';

sealed class FolderState extends Equatable {
  const FolderState();

  @override
  List<Object?> get props => [];
}

/// The folders are being loaded.
final class FolderLoadingState extends FolderState {
  const FolderLoadingState();
}

/// The folders couldn't be loaded.
final class FolderErrorState extends FolderState {
  const FolderErrorState();
}

/// The folders are loaded and shown.
final class FolderSuccessState extends FolderState {
  const FolderSuccessState({
    this.folderItemsList = const [],
    this.isFolderCreating = false,
    this.action,
    this.totalAvailableUrl = 0,
  });

  /// One item per folder, with its URL count and first URL.
  final List<FolderItem> folderItemsList;

  /// Whether a folder is being created; drives the create button's loading
  /// state.
  final bool isFolderCreating;

  /// One-shot UI action for the view to perform, or `null` if there is none.
  final FolderAction? action;

  /// Total Available Url in the Database.
  final int totalAvailableUrl;

  @override
  List<Object?> get props => [
    folderItemsList,
    isFolderCreating,
    action,
    totalAvailableUrl,
  ];

  FolderSuccessState copyWith({
    List<FolderItem>? folderItemsList,
    bool? isFolderCreating,
    FolderAction? action,
    bool clearAction = false,
    int? totalAvailableUrl,
  }) {
    return FolderSuccessState(
      folderItemsList: folderItemsList ?? this.folderItemsList,
      isFolderCreating: isFolderCreating ?? this.isFolderCreating,
      action: clearAction ? null : (action ?? this.action),
      totalAvailableUrl: totalAvailableUrl ?? this.totalAvailableUrl,
    );
  }

  @override
  String toString() {
    return 'FolderSuccessState{folderItemsList: $folderItemsList, isFolderCreating: $isFolderCreating, action: $action, totalAvailableUrl: $totalAvailableUrl}';
  }
}

/// A folder shown in the list, with its URL count and first URL.
class FolderItem extends Equatable {
  const FolderItem({
    required this.folder,
    required this.totalUrl,
    required this.firstUrl,
  });

  final Folder folder;

  /// Number of URLs in the folder.
  final int totalUrl;

  /// Address of the folder's earliest saved URL, or `null` if it has none.
  final String? firstUrl;

  @override
  List<Object?> get props => [folder.id, folder.folderName, totalUrl, firstUrl];

  @override
  String toString() {
    return 'FolderItem{folder: $folder, totalUrl: $totalUrl, firstUrl: $firstUrl}';
  }
}
