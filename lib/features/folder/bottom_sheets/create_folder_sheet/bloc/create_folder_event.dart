import 'package:equatable/equatable.dart';

sealed class CreateFolderEvent extends Equatable {
  const CreateFolderEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the folder name is edited.
final class OnNameChanged extends CreateFolderEvent {
  const OnNameChanged(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

/// Triggered when the "Create Folder" button, or done on the keyboard, is
/// tapped.
final class OnCreateClicked extends CreateFolderEvent {
  const OnCreateClicked();
}

/// Triggered when a one-shot UI action has been consumed by the view.
final class OnActionHandled extends CreateFolderEvent {
  const OnActionHandled();
}
