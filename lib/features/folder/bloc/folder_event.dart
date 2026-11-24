import 'package:equatable/equatable.dart';

sealed class FolderEvent extends Equatable {
  const FolderEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the page opens, to load the folders.
final class OnInitEvent extends FolderEvent {
  const OnInitEvent();
}

/// Triggered when the refresh icon is tapped, to load the folders again.
final class OnRefreshClicked extends FolderEvent {
  const OnRefreshClicked();
}

/// Triggered when the folder [folderId] is tapped in the list.
final class OnFolderItemClicked extends FolderEvent {
  const OnFolderItemClicked({required this.folderId});

  final int folderId;

  @override
  List<Object?> get props => [folderId];
}

/// Triggered when the "Create Folder" button is clicked.
final class OnCreateFolderClicked extends FolderEvent {
  const OnCreateFolderClicked();
}

/// Triggered when a one-shot UI action has been consumed by the view.
final class OnActionHandled extends FolderEvent {
  const OnActionHandled();
}
