import 'package:equatable/equatable.dart';
import 'package:keep_links/core/data/database/entity/tag.dart';
import 'package:keep_links/features/add_new_link/bottom_sheets/tag_selection_sheet/bloc/tag_selection_action.dart';
import 'package:keep_links/features/add_new_link/bottom_sheets/tag_selection_sheet/bloc/tag_selection_bloc.dart';

export 'package:keep_links/features/add_new_link/bottom_sheets/tag_selection_sheet/bloc/tag_selection_action.dart';

final class TagSelectionState extends Equatable {
  const TagSelectionState({
    this.isLoading = true,
    this.tags = const [],
    this.selectedTags = const [],
    this.totalTagCount = 0,
    this.isCreating = false,
    this.action,
  });

  final bool isLoading;
  final List<TagItem> tags;
  final List<Tag> selectedTags;
  final int totalTagCount;
  final bool isCreating;
  final TagSelectionAction? action;

  factory TagSelectionState.initial(List<Tag> initialSelectedTags) {
    return TagSelectionState(
      isLoading: true,
      tags: const [],
      selectedTags: List<Tag>.unmodifiable(initialSelectedTags),
      totalTagCount: 0,
      isCreating: false,
    );
  }

  TagSelectionState copyWith({
    bool? isLoading,
    List<TagItem>? tags,
    List<Tag>? selectedTags,
    int? totalTagCount,
    bool? isCreating,
    TagSelectionAction? action,
    bool clearAction = false,
  }) {
    return TagSelectionState(
      isLoading: isLoading ?? this.isLoading,
      tags: tags ?? this.tags,
      selectedTags: selectedTags ?? this.selectedTags,
      totalTagCount: totalTagCount ?? this.totalTagCount,
      isCreating: isCreating ?? this.isCreating,
      action: clearAction ? null : (action ?? this.action),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    tags,
    selectedTags,
    totalTagCount,
    isCreating,
    action,
  ];

  @override
  String toString() {
    return 'TagSelectionState{isLoading: $isLoading, tags: $tags, selectedTags: $selectedTags, totalTagCount: $totalTagCount, isCreating: $isCreating, action: $action}';
  }
}
