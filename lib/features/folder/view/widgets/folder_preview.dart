import 'package:flutter/material.dart';
import 'package:keep_links/features/theme/colors.dart';

/// A stack of up to three layers previewing a folder's links.
///
/// The first (front) layer is always shown and holds the folder's first URL.
/// The second layer is shown from two links, and the third from three.
class FolderPreview extends StatelessWidget {
  const FolderPreview({
    super.key,
    required this.totalUrl,
    required this.firstUrl,
  });

  static const double _layerHeight = 56;

  /// How far each layer sticks out above, and is inset from, the one in front.
  static const double _layerOffset = 8;

  static const double totalHeight = _layerHeight + _layerOffset * 2;

  /// Number of URLs in the folder.
  final int totalUrl;

  /// Address shown on the first layer, or `null` if the folder has no URLs.
  final String? firstUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: totalHeight,
      child: Stack(
        children: [
          if (totalUrl > 2)
            _buildLayer(
              offset: _layerOffset * 2,
              color: const Color(0xFFF8E3D0),
              borderColor: const Color(0xFFF1D5BC),
            ),
          if (totalUrl > 1)
            _buildLayer(
              offset: _layerOffset,
              color: const Color(0xFFFCEEDF),
              borderColor: const Color(0xFFF1D5BC),
            ),
          _buildLayer(
            offset: 0,
            color: Colors.white,
            borderColor: const Color(0xFFE8C9A8),
            child: _buildUrlText(),
          ),
        ],
      ),
    );
  }

  Widget _buildLayer({
    required double offset,
    required Color color,
    required Color borderColor,
    Widget? child,
  }) {
    return Positioned(
      left: offset,
      right: offset,
      bottom: offset,
      height: _layerHeight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: child,
      ),
    );
  }

  Widget _buildUrlText() {
    final url = firstUrl;
    return Text(
      url ?? 'No links yet',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        fontWeight: url == null ? FontWeight.w400 : FontWeight.w500,
        color: url == null
            ? const Color(0xFF857B74)
            : KeepLinksColors.appBarTitleColor,
      ),
    );
  }
}
