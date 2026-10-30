import 'package:flutter/material.dart';

class ExportBottomSheetWidget extends StatelessWidget {
  const ExportBottomSheetWidget({
    super.key,
    required this.count,
    this.onExport,
  });

  final int count;
  final VoidCallback? onExport;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0D5CE),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Export Bookmarks',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E1B18),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You currently have $count bookmark(s) ready to export.',
              style: const TextStyle(fontSize: 14, color: Color(0xFF52443D)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB38E),
                  foregroundColor: const Color(0xFF7A4326),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  onExport?.call();
                },
                child: const Text('Export'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
