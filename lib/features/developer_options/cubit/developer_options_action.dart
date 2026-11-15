import 'package:equatable/equatable.dart';

sealed class DeveloperOptionsAction extends Equatable {
  const DeveloperOptionsAction();

  @override
  List<Object?> get props => [];
}

final class ShowToast extends DeveloperOptionsAction {
  const ShowToast(this.message);

  final String message;

  @override
  List<Object?> get props => [message];

  @override
  String toString() {
    return 'ShowToast{message: $message}';
  }
}
