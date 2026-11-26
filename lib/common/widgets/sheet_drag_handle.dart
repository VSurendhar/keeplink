import 'package:flutter/material.dart';

/// The small bar at the top of a bottom sheet.
class SheetDragHandle extends StatelessWidget {
  const SheetDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
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
}
