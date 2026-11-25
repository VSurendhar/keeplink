import 'package:flutter/material.dart';

class MoveAllToTrashConfirmationWidget extends StatelessWidget {
  const MoveAllToTrashConfirmationWidget({super.key, required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    const dangerActionColor = Color(0xFFC83838);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Move All Links to Trash',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: dangerActionColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Are you sure you want to move all your saved links to the trash?\nTheir folders and tags move too, and come back when you restore a link. Folders and tags that no link uses are permanently deleted.',
              style: TextStyle(fontSize: 14, color: Color(0xFF7A4326)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF857B74)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dangerActionColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm();
                  },
                  child: const Text('Move'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
