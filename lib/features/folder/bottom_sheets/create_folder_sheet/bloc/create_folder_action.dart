import 'package:equatable/equatable.dart';

sealed class CreateFolderAction extends Equatable {
  const CreateFolderAction();

  @override
  List<Object?> get props => [];
}

/// Triggered when the view should show a toast with [message].
final class ShowToast extends CreateFolderAction {
  const ShowToast(this.message);

  final String message;

  @override
  List<Object?> get props => [message];

  @override
  String toString() {
    return 'ShowToast{message: $message}';
  }
}

/// Triggered after the folder is created: the view shows [message] as a toast
/// and closes the sheet.
final class CloseWithMessage extends CreateFolderAction {
  const CloseWithMessage(this.message);

  final String message;

  @override
  List<Object?> get props => [message];

  @override
  String toString() {
    return 'CloseWithMessage{message: $message}';
  }
}
