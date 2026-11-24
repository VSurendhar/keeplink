import 'package:flutter/material.dart';
import 'package:keep_links/features/folder/bloc/folder_state.dart';
import 'package:keep_links/features/folder/view/widgets/folder_preview.dart';
import 'package:keep_links/features/theme/colors.dart';

/// A folder in the grid: its name, link count and link preview.
class FolderCard extends StatelessWidget {
  const FolderCard({super.key, required this.item, required this.onTap});

  static const double _titleFontSize = 16;
  static const double _countFontSize = 12;
  static const double _lineHeight = 1.5;

  final FolderItem item;

  final VoidCallback onTap;

  static double heightOf(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    final textHeight =
        (textScaler.scale(_titleFontSize) + textScaler.scale(_countFontSize)) *
        _lineHeight;
    // Paddings, borders and gaps around the texts and the preview.
    const spacing = 68.0;
    return spacing + textHeight + FolderPreview.totalHeight;
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(24);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D2926).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: const BorderSide(color: Color(0xFFF5E1D3)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.folder.folderName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: _titleFontSize,
                    height: _lineHeight,
                    fontWeight: FontWeight.w500,
                    color: KeepLinksColors.headerTitleColor,
                  ),
                ),
                const SizedBox(height: 4),
                _buildCountChip(),
                const Spacer(),
                FolderPreview(totalUrl: item.totalUrl, firstUrl: item.firstUrl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountChip() {
    final totalUrl = item.totalUrl;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF5E1D3)),
      ),
      child: Text(
        totalUrl == 1 ? '1 link' : '$totalUrl links',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: _countFontSize,
          height: _lineHeight,
          fontWeight: FontWeight.w500,
          color: KeepLinksColors.appBarTitleColor,
        ),
      ),
    );
  }
}
