import 'package:equatable/equatable.dart';
import 'package:mindful_links/core/data/database/entity/folder.dart';

sealed class FolderSelectionAction extends Equatable {
  const FolderSelectionAction();

  @override
  List<Object?> get props => [];
}

/// Closes the sheet and returns [folder] as the selected folder.
final class CloseWithSelectedFolder extends FolderSelectionAction {
  const CloseWithSelectedFolder(this.folder);

  final Folder folder;

  @override
  List<Object?> get props => [folder];
}

final class ShowToast extends FolderSelectionAction {
  const ShowToast(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
