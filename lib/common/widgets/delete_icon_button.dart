import 'package:flutter/material.dart';

/// A round, muted delete (trash) icon button, used on deletable list and
/// grid items such as folders and tags.
class DeleteIconButton extends StatelessWidget {
  const DeleteIconButton({
    super.key,
    required this.onTap,
    this.padding = const EdgeInsets.all(8),
  });

  /// Called when the user taps the icon.
  final VoidCallback onTap;

  /// Space around the icon, which also enlarges the tap target.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: padding,
        child: const Icon(
          Icons.delete_outline_rounded,
          size: 20,
          color: Color(0xFF9E8E85),
        ),
      ),
    );
  }
}
