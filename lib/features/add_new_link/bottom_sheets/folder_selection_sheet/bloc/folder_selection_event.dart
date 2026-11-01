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

