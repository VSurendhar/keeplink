import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindful_links/core/data/database/entity/tag.dart';
import 'package:mindful_links/features/add_new_link/bottom_sheets/tag_selection_sheet/bloc/tag_selection_bloc.dart';
import 'package:mindful_links/features/add_new_link/bottom_sheets/tag_selection_sheet/bloc/tag_selection_event.dart';
import 'package:mindful_links/features/add_new_link/bottom_sheets/tag_selection_sheet/bloc/tag_selection_state.dart';
import 'package:mindful_links/features/theme/theme.dart';

class TagSelectionSheetWidget extends StatelessWidget {
  const TagSelectionSheetWidget({super.key});

  bool _isTagSelected(List<Tag> selectedTags, Tag tag) {
    return selectedTags.any((t) => t.tagName == tag.tagName && t.id == tag.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TagSelectionBloc, TagSelectionState>(
      builder: (context, state) {
        final selectedTags = state.selectedTags;
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDragHandle(),
                const SizedBox(height: 16),
                _buildHeader(context, selectedTags),
                const SizedBox(height: 16),
                _buildCreateNewTagRow(),
                const SizedBox(height: 12),
                Flexible(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: state.isLoading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLibraryHeader(state.totalTagCount),
                              const SizedBox(height: 8),
                              _buildTagGrid(context, state),
                              const SizedBox(height: 16),
                              _buildApplyButton(context, selectedTags),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 32,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFE0D5CE),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<Tag> selectedTags) {
    final selectedCount = selectedTags.length;

    return Row(
      children: [
        const Text(
          'Select Tags',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E1B18),
          ),
        ),
        if (selectedCount > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: MindfulLinksTheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$selectedCount Selected',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7A4326),
              ),
            ),
          ),
        ],
        const Spacer(),
        if (selectedCount > 0)
          GestureDetector(
            onTap: () {
              context.read<TagSelectionBloc>().add(const OnClearAllRequested());
            },
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                'Clear',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF857B74),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCreateNewTagRow() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0D5CE), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO "Navigate to Create Tag UI"
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: MindfulLinksTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.add_rounded,
                    color: Color(0xFF7A4326),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Create New Tag',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E1B18),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Type name to create on the fly',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF857B74),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLibraryHeader(int totalTagCount) {
    return Row(
      children: [
        const Text(
          'Available Tags',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9E8E85),
          ),
        ),
        const Spacer(),
        Text(
          '$totalTagCount Tags',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF9E8E85),
          ),
        ),
      ],
    );
  }

  Widget _buildTagGrid(BuildContext context, TagSelectionState state) {
    if (state.tags.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No tags found',
            style: TextStyle(fontSize: 14, color: Color(0xFF9E8E85)),
          ),
        ),
      );
    }

    return Expanded(
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2.5,
        ),
        itemCount: state.tags.length,
        itemBuilder: (context, index) {
          return _buildTagGridItem(
            context,
            state.tags[index],
            state.selectedTags,
          );
        },
      ),
    );
  }

  Widget _buildTagGridItem(
    BuildContext context,
    TagItem item,
    List<Tag> selectedTags,
  ) {
    final tag = item.tag;
    final isSelected = _isTagSelected(selectedTags, tag);

    return Material(
      color: isSelected ? const Color(0xFFFAF0E8) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: () {
          context.read<TagSelectionBloc>().add(OnTagToggled(tag));
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? MindfulLinksTheme.primary
                  : const Color(0xFFF0E8E2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '#${tag.tagName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF7A4326)
                            : const Color(0xFF1E1B18),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.linkCount} links',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF857B74),
                      ),
                    ),
                  ],
                ),
              ),
              _buildTagSelectionIndicator(isSelected),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagSelectionIndicator(bool isSelected) {
    if (isSelected) {
      return Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          color: Color(0xFF7A4326),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 12),
      );
    }
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: Color(0xFFF5EDE8),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildApplyButton(BuildContext context, List<Tag> selectedTags) {
    final count = selectedTags.length;
    final hasSelection = count > 0;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: hasSelection
              ? const Color(0xFF7A4326)
              : const Color(0xFFE0D5CE),
          foregroundColor: hasSelection
              ? Colors.white
              : const Color(0xFF9E8E85),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        onPressed: hasSelection
            ? () {
                Navigator.pop(context, selectedTags);
              }
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Apply $count ${count == 1 ? 'Tag' : 'Tags'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}
