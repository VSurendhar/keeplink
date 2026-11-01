import 'package:equatable/equatable.dart';

sealed class FolderSelectionAction extends Equatable {
  const FolderSelectionAction();

  @override
  List<Object?> get props => [];
}

final class ShowToast extends FolderSelectionAction {
  const ShowToast(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

