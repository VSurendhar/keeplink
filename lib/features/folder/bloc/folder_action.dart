import 'package:equatable/equatable.dart';

sealed class FolderAction extends Equatable {
  const FolderAction();

  @override
  List<Object?> get props => [];
}

/// Triggered when the view should open the create folder dialog.
final class ShowCreateFolderDialog extends FolderAction {
  const ShowCreateFolderDialog();
}

/// Triggered when the view should open the screen listing the URLs of the
/// folder [folderId].
final class NavigateToFolderUrlsScreen extends FolderAction {
  const NavigateToFolderUrlsScreen({required this.folderId});

  final int folderId;

  @override
  List<Object?> get props => [folderId];

  @override
  String toString() {
    return 'NavigateToFolderUrlsScreen{folderId: $folderId}';
  }
}
