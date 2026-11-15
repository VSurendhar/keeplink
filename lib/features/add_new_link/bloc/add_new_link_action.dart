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
