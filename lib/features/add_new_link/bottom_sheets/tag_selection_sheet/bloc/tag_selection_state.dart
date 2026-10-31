import 'package:equatable/equatable.dart';
import 'package:mindful_links/core/data/database/entity/tag.dart';
import 'package:mindful_links/features/add_new_link/bottom_sheets/tag_selection_sheet/bloc/tag_selection_bloc.dart';

final class TagSelectionState extends Equatable {
  const TagSelectionState({
    this.isLoading = true,
    this.tags = const [],
    this.selectedTags = const [],
    this.totalTagCount = 0,
  });

  final bool isLoading;
  final List<TagItem> tags;
  final List<Tag> selectedTags;
  final int totalTagCount;

  factory TagSelectionState.initial(List<Tag> initialSelectedTags) {
    return TagSelectionState(
      isLoading: true,
      tags: const [],
      selectedTags: List<Tag>.unmodifiable(initialSelectedTags),
      totalTagCount: 0,
    );
  }

  TagSelectionState copyWith({
    bool? isLoading,
    List<TagItem>? tags,
    List<Tag>? selectedTags,
    int? totalTagCount,
    bool clearAction = false,
  }) {
    return TagSelectionState(
      isLoading: isLoading ?? this.isLoading,
      tags: tags ?? this.tags,
      selectedTags: selectedTags ?? this.selectedTags,
      totalTagCount: totalTagCount ?? this.totalTagCount,
    );
  }

  @override
  List<Object?> get props => [isLoading, tags, selectedTags, totalTagCount];

  @override
  String toString() {
    return 'TagSelectionState{isLoading: $isLoading, tags: $tags, selectedTags: $selectedTags, totalTagCount: $totalTagCount}';
  }
}
