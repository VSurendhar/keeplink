import 'package:equatable/equatable.dart';
import 'package:mindful_links/core/data/database/entity/folder.dart';

sealed class FolderSelectionAction extends Equatable {
  const FolderSelectionAction();

  @override
  List<Object?> get props => [];
}

/// Closes the sheet and returns [folder] as the selected folder, showing
/// [message] as a toast when it is set.
final class CloseWithSelectedFolder extends FolderSelectionAction {
  const CloseWithSelectedFolder(this.folder, {this.message});

  final Folder folder;
  final String? message;

  @override
  List<Object?> get props => [folder, message];

  @override
  String toString() {
    return 'CloseWithSelectedFolder{folder: $folder, message: $message}';
  }
}

final class ShowToast extends FolderSelectionAction {
  const ShowToast(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
