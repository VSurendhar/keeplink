import 'package:keep_links/core/data/database/entity/folder.dart';
import 'package:keep_links/core/data/database/entity/tag.dart';
import 'package:keep_links/core/data/hive/models/app_settings.dart';

class AppDefaults {
  static final defaultFolders = List.unmodifiable([
    Folder(folderName: "Defaults"),
  ]);
  static final List<Tag> defaultTags = List.unmodifiable([
    Tag(tagName: 'Tag1'),
  ]);
  static const AppLanguage appLanguage = AppLanguage.englishUs;
  static const int trashRetention = 10;
  static const AppTheme appTheme = AppTheme.light;
  static const int linkNameMaxLength = 40;
  static const int folderNameMaxLength = 40;
}
