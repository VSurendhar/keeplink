import 'package:equatable/equatable.dart';
import 'package:mindful_links/core/data/database/entity/tag.dart';

sealed class TagSelectionEvent extends Equatable {
  const TagSelectionEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered to initialize the tag selection sheet with database items.
final class OnTagInit extends TagSelectionEvent {
  const OnTagInit();
}

/// Triggered when a tag is toggled in the sheet.
final class OnTagToggled extends TagSelectionEvent {
  const OnTagToggled(this.tag);

  final Tag tag;

  @override
  List<Object?> get props => [tag.id, tag.tagName];
}

/// Triggered when a tag is removed from the attached chips.
final class OnTagRemove extends TagSelectionEvent {
  const OnTagRemove(this.tag);

  final Tag tag;

  @override
  List<Object?> get props => [tag.id, tag.tagName];
}

/// Triggered when the "Clear" button is tapped in the sheet.
final class OnClearAllRequested extends TagSelectionEvent {
  const OnClearAllRequested();
}

/// Triggered to toggle the create tag input view.
final class OnToggleCreateMode extends TagSelectionEvent {
  const OnToggleCreateMode();
}

/// Triggered when the user taps the save button to create a new tag.
final class OnSaveTagClicked extends TagSelectionEvent {
  const OnSaveTagClicked();
}

/// Triggered when a one-shot UI action has been consumed by the view.
final class OnActionHandled extends TagSelectionEvent {
  const OnActionHandled();
}


