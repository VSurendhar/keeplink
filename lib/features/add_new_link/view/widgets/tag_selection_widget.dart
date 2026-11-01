import 'package:flutter/material.dart';
import 'package:mindful_links/core/data/database/entity/tag.dart';

class TagSelectionWidget extends StatelessWidget {
  const TagSelectionWidget({
    super.key,
    required this.tags,
    this.onRemoveTag,
    this.onAddTagTap,
  });

  final List<Tag> tags;
  final ValueChanged<Tag>? onRemoveTag;
  final VoidCallback? onAddTagTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 8,
      children: [
        ...tags.map((tag) => _buildTagChip(tag)),
        _buildAddTagButton(),
      ],
    );
  }

  Widget _buildTagChip(Tag tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x33FFB38E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag.tagName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E1B18),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => onRemoveTag?.call(tag),
            behavior: HitTestBehavior.opaque,
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: Color(0xFF52443D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTagButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onAddTagTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2D6CF), width: 1),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '+ Add Tag',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF857B74),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
