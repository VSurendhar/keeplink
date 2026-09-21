import 'package:flutter/material.dart';

class BottomNavIcon extends StatelessWidget {
  const BottomNavIcon({
    super.key,
    required this.filledIcon,
    required this.unfilledIcon,
    required this.isSelected,
    required this.onPressed,
  });

  final IconData filledIcon;
  final IconData unfilledIcon;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isSelected)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              Icon(
                isSelected ? filledIcon : unfilledIcon,
                size: 20,
                color: colors.onSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
