import 'package:flutter/material.dart';

class EraseAllConfirmationWidget extends StatelessWidget {
  const EraseAllConfirmationWidget({super.key, required this.onErase});

  final VoidCallback onErase;

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
              'Erase All Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: dangerActionColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Are you sure you want to erase all your saved URLs, folders, and tags?\nThis action cannot be undone.',
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
                    onErase();
                  },
                  child: const Text('Erase'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
