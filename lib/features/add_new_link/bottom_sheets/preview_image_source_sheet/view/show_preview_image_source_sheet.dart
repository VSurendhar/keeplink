import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Asks where the preview image should come from.
///
/// Returns the chosen [ImageSource], or `null` if the sheet was dismissed.
Future<ImageSource?> showPreviewImageSourceSheet(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOption(
              context,
              icon: Icons.photo_library_outlined,
              label: 'Choose from gallery',
              source: ImageSource.gallery,
            ),
            _buildOption(
              context,
              icon: Icons.photo_camera_outlined,
              label: 'Take photo',
              source: ImageSource.camera,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildOption(
  BuildContext context, {
  required IconData icon,
  required String label,
  required ImageSource source,
}) {
  return ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    leading: Icon(icon, color: const Color(0xFF7A4326)),
    title: Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    ),
    onTap: () => Navigator.pop(context, source),
  );
}
