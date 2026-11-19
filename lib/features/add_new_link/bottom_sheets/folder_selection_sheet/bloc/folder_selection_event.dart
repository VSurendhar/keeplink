import 'package:equatable/equatable.dart';
import 'package:keep_links/core/data/database/entity/folder.dart';

sealed class FolderSelectionEvent extends Equatable {
  const FolderSelectionEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered to initialize the folder selection sheet with database items.
final class OnInitEvent extends FolderSelectionEvent {
  const OnInitEvent();
}

/// Triggered to toggle the create folder input view.
final class OnToggleCreateMode extends FolderSelectionEvent {
  const OnToggleCreateMode();
}

/// Triggered when the user taps the save button to create a new folder.
final class OnSaveFolderClicked extends FolderSelectionEvent {
  const OnSaveFolderClicked();
}

/// Triggered when the user taps the delete icon on a folder.
final class OnDeleteFolderClicked extends FolderSelectionEvent {
  const OnDeleteFolderClicked(this.folder);

  final Folder folder;

  @override
  List<Object?> get props => [folder.id, folder.folderName];
}

/// Triggered when a one-shot UI action has been consumed by the view.
final class OnActionHandled extends FolderSelectionEvent {
  const OnActionHandled();
}
