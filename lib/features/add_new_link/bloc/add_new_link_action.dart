import 'package:equatable/equatable.dart';

sealed class AddNewLinkAction extends Equatable {
  const AddNewLinkAction();

  @override
  List<Object?> get props => [];
}

/// Triggered when the view should open the Folder Selection bottom sheet.
final class ShowFolderSelectionSheetAction extends AddNewLinkAction {
  const ShowFolderSelectionSheetAction();
}

/// Triggered when the view should open the Tag Selection bottom sheet.
final class ShowTagSelectionSheetAction extends AddNewLinkAction {
  const ShowTagSelectionSheetAction();
}

/// Triggered when the view should show a toast with [message].
final class ShowToast extends AddNewLinkAction {
  const ShowToast(this.message);

  final String message;

  @override
  List<Object?> get props => [message];

  @override
  String toString() {
    return 'ShowToast{message: $message}';
  }
}

/// Triggered after the link is saved: the view shows [message] as a toast and
/// closes the page.
final class CloseWithMessage extends AddNewLinkAction {
  const CloseWithMessage(this.message);

  final String message;

  @override
  List<Object?> get props => [message];

  @override
  String toString() {
    return 'CloseWithMessage{message: $message}';
  }
}
