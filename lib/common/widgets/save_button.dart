import 'package:flutter/material.dart';
import 'package:mindful_links/features/theme/theme.dart';

/// A "Save" button for pages that let the user edit data and then persist it explicitly
///
/// It is driven by three inputs:
/// - [isEnabled]: whether there is anything to save.
/// - [onPressed]: what to do when the user taps Save.
/// - [isLoading]: whether a save is currently in progress.
///
/// Visual states:
/// - **Disabled** (`isEnabled == false`, `isLoading == false`): muted
///   background and text, taps are ignored.
/// - **Enabled** (`isEnabled == true`, `isLoading == false`): primary
///   background with the "Save" label, taps call [onPressed].
/// - **Loading** (`isLoading == true`): keeps the enabled colors but replaces
///   the "Save" label with an [CircularProgressIndicator] and ignores
///   taps, so a second save cannot start while one is running. The label still
///   takes up its space (it is only hidden), so the button does not resize
///   when the indicator appears or disappears.
class SaveButton extends StatelessWidget {
  const SaveButton({
    super.key,
    required this.isEnabled,
    required this.onPressed,
    this.isLoading = false,
  });

  /// Whether the button can be tapped.
  ///
  /// Set it to `true` only when there is something to save. When `false`
  /// the button is shown in its muted, disabled style and taps are ignored.
  final bool isEnabled;

  /// Called when the user taps the button.
  ///
  /// Triggered only when [isEnabled] is `true` and [isLoading] is `false`.
  /// Typically it dispatches a save event to the page's BLoC, which performs
  /// the actual persistence.
  final VoidCallback onPressed;

  /// Whether a save operation is in progress.
  ///
  /// Set it to `true` when the save starts and back to `false` once it
  /// finishes, whether it succeeds or fails. While `true`, the button shows a
  /// circular progress indicator in place of its label and ignores taps.
  /// Defaults to `false` for pages that save synchronously or don't need
  /// progress feedback.
  final bool isLoading;

  static const _buttonTextColor = Color(0xFF7A4326);
  static const _disabledTextColor = Color(0xFF9E8E85);
  static const _indicatorSize = 16.0;

  @override
  Widget build(BuildContext context) {
    // While loading, keep the enabled look even though taps are blocked.
    final looksEnabled = isEnabled || isLoading;
    final textColor = looksEnabled ? _buttonTextColor : _disabledTextColor;

    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: looksEnabled
            ? MindfulLinksTheme.primary
            : const Color(0xFFE0D5CE),
        disabledBackgroundColor: isLoading ? MindfulLinksTheme.primary : null,
        foregroundColor: textColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      onPressed: isEnabled && !isLoading ? onPressed : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Hidden (not removed) while loading so the button keeps its size.
          Visibility(
            visible: !isLoading,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: Text(
              'Save',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          // Progress indicator shown inside the button while saving.
          if (isLoading)
            const SizedBox(
              width: _indicatorSize,
              height: _indicatorSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _buttonTextColor,
              ),
            ),
        ],
      ),
    );
  }
}
