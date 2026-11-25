import 'package:flutter/widgets.dart';
import 'package:keep_links/core/utils/app_defaults.dart';

/// Checks folder names, wherever a folder is created.
class FolderNameValidator {
  /// Returns the message to show if the trimmed [name] can't be used, or `null`
  /// if it can.
  ///
  /// Counts visible characters, so an emoji is one character.
  static String? validate(String name) {
    if (name.isEmpty ||
        name.characters.length > AppDefaults.folderNameMaxLength) {
      return 'Folder name must be between 1 and ${AppDefaults.folderNameMaxLength} characters';
    }
    return null;
  }
}
