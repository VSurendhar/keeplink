import 'package:mindful_links/core/data/database/entity/folder.dart';
import 'package:mindful_links/core/data/database/entity/tag.dart';

class AppDefaults {
  static final defaultFolders = List.unmodifiable([
    Folder(folderName: "Defaults"),
  ]);
  static final List<Tag> defaultTags = List.unmodifiable([
    Tag(tagName: 'Tag1'),
  ]);
}
