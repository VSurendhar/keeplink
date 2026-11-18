import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindful_links/core/data/database/entity/folder.dart';
import 'package:mindful_links/core/data/database/entity/tag.dart';

sealed class AddNewLinkEvent extends Equatable {
  const AddNewLinkEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the page opens, to load the default folder with its id.
final class OnInitEvent extends AddNewLinkEvent {
  const OnInitEvent();
}

/// Triggered when the link name input changes.
final class OnNameChanged extends AddNewLinkEvent {
  const OnNameChanged(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

/// Triggered when the URL input is entered or changed.
final class OnUrlChanged extends AddNewLinkEvent {
  const OnUrlChanged(this.url);

  final String url;

  @override
  List<Object?> get props => [url];
}

/// Triggered when the user requests to open the folder selection bottom sheet.
final class OnShowFolderSheetRequested extends AddNewLinkEvent {
  const OnShowFolderSheetRequested();
}

/// Triggered when the user requests to open the tag selection bottom sheet.
final class OnShowTagSheetRequested extends AddNewLinkEvent {
  const OnShowTagSheetRequested();
}

/// Triggered when a folder is selected from the folder bottom sheet.
final class OnFolderSelected extends AddNewLinkEvent {
  const OnFolderSelected({required this.folder});

  final Folder folder;

  @override
  List<Object?> get props => [folder.id];
}

/// Triggered when tags are selected from the tag selection bottom sheet.
final class OnTagsSelected extends AddNewLinkEvent {
  const OnTagsSelected(this.tags);

  final List<Tag> tags;

  @override
  List<Object?> get props => [tags.map((tag) => tag.id)];
}

/// Triggered when a tag chip is removed from the screen.
final class OnTagRemoved extends AddNewLinkEvent {
  const OnTagRemoved(this.tag);

  final Tag tag;

  @override
  List<Object?> get props => [tag];
}

/// Triggered when the preview image box is tapped, to open the image source
/// bottom sheet.
final class OnShowPreviewImageSourceSheetRequested extends AddNewLinkEvent {
  const OnShowPreviewImageSourceSheetRequested();
}

/// Triggered when an image [source] (gallery or camera) is chosen for the
/// preview image.
final class OnPickPreviewImageRequested extends AddNewLinkEvent {
  const OnPickPreviewImageRequested(this.source);

  final ImageSource source;

  @override
  List<Object?> get props => [source];
}

/// Triggered when the "Save Link" button is clicked.
final class OnSaveClicked extends AddNewLinkEvent {
  const OnSaveClicked();
}

/// Triggered when a one-shot UI action has been consumed by the view.
final class OnActionHandled extends AddNewLinkEvent {
  const OnActionHandled();
}
