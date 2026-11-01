import 'package:equatable/equatable.dart';

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
