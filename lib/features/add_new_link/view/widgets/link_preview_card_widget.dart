import 'package:flutter/material.dart';

class LinkPreviewCardWidget extends StatelessWidget {
  const LinkPreviewCardWidget({super.key, this.previewImageUrl});

  final String? previewImageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D2926).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: const BoxDecoration(color: Color(0xFFE8EEF4)),
              child: previewImageUrl != null
                  ? Image.network(
                      previewImageUrl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          SizedBox.shrink(),
                    )
                  : SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
