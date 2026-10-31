import 'package:equatable/equatable.dart';
import 'package:mindful_links/core/data/database/entity/folder.dart';

sealed class FolderSelectionEvent extends Equatable {
  const FolderSelectionEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered to initialize the folder selection sheet with database items.
final class OnInitEvent extends FolderSelectionEvent {
  const OnInitEvent();
}

/// Triggered when the user taps on a folder item.
final class OnFolderSelected extends FolderSelectionEvent {
  const OnFolderSelected(this.folder);

  final Folder folder;

  @override
  List<Object?> get props => [folder.id, folder.folderName];
}
