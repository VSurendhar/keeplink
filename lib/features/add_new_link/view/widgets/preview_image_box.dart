import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mindful_links/common/widgets/dashed_border_painter.dart';
import 'package:mindful_links/core/constants.dart';

/// The link's preview image box, shaped to [kPreviewImageAspectRatio].
///
/// States:
/// - **Empty** ([imagePath] is `null`): dashed border, camera icon and
///   "Add preview image".
/// - **Saving** ([isSaving]): same box with a centred spinner; taps are
///   ignored.
/// - **Image**: the file at [imagePath], cropped to fill the box. Falls back
///   to the empty state if the file can't be read.
///
/// Tapping the box (except while saving) calls [onTap].
class PreviewImageBox extends StatelessWidget {
  const PreviewImageBox({
    super.key,
    required this.imagePath,
    required this.isSaving,
    required this.onTap,
  });

  final String? imagePath;
  final bool isSaving;
  final VoidCallback onTap;

  static const double _radius = 16;
  static const double _borderWidth = 1.5;
  static const double _iconSize = 32;
  static const Color _accentColor = Color(0xFF7A4326);
  static const Color _labelColor = Color(0xFF857B74);
  static const Color _borderColor = Color(0xFFE0D5CE);
  static const Color _backgroundColor = Color(0xFFF5EDE8);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: kPreviewImageAspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: Stack(
          children: [
            Positioned.fill(child: _buildContent()),
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(onTap: isSaving ? null : onTap),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isSaving) {
      return _buildDashedFrame(
        child: const CircularProgressIndicator(color: _accentColor),
      );
    }
    final path = imagePath;
    if (path == null) return _buildEmpty();
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildEmpty(),
    );
  }

  Widget _buildEmpty() {
    return _buildDashedFrame(
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.photo_camera_outlined,
            color: _accentColor,
            size: _iconSize,
          ),
          SizedBox(height: 8),
          Text(
            'Add preview image',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _labelColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedFrame({required Widget child}) {
    return CustomPaint(
      foregroundPainter: const DashedBorderPainter(
        color: _borderColor,
        strokeWidth: _borderWidth,
        radius: _radius,
      ),
      child: ColoredBox(
        color: _backgroundColor,
        child: Center(child: child),
      ),
    );
  }
}
