import 'package:equatable/equatable.dart';

sealed class TagSelectionAction extends Equatable {
  const TagSelectionAction();

  @override
  List<Object?> get props => [];
}

final class ShowToast extends TagSelectionAction {
  const ShowToast(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

