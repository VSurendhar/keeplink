import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

/// Paints a dashed rounded-rectangle border inside the canvas bounds.
///
/// Use it as a `foregroundPainter` of a [CustomPaint] so the border is drawn
/// on top of the child.
class DashedBorderPainter extends CustomPainter {
  const DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    this.dashLength = 8,
    this.gapLength = 4,
  });

  final Color color;
  final double strokeWidth;
  final double radius;

  /// Length of each dash along the border.
  final double dashLength;

  /// Space between two dashes.
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Inset by half the stroke so the whole line stays inside the box.
    final inset = strokeWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final border = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius - inset)));

    for (final PathMetric metric in border.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = distance + dashLength;
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.radius != radius ||
      oldDelegate.dashLength != dashLength ||
      oldDelegate.gapLength != gapLength;
}
