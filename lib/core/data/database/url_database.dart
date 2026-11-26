import 'dart:async';

import 'package:floor/floor.dart';
import 'package:keep_links/core/data/database/dao/url_dao.dart';
import 'package:keep_links/core/data/database/entity/folder.dart';
import 'package:keep_links/core/data/database/entity/tag.dart';
import 'package:keep_links/core/data/database/entity/url.dart';
import 'package:keep_links/core/data/database/entity/url_tag.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'url_database.g.dart';

@Database(version: 1, entities: [Url, UrlTag, Folder, Tag])
abstract class UrlDatabase extends FloorDatabase {
  UrlDao get urlDao;
}

/// Creates the unique indexes on `url` and `title` that cover saved URLs only,
/// so a trashed URL doesn't reserve its address or title.
///
/// Floor's `Index` can't declare a partial index (one with a `WHERE` clause).
final urlDatabaseCallback = Callback(
  onCreate: (database, version) async {
    await database.execute(
      'CREATE UNIQUE INDEX `index_url_url` ON `url` (`url`) WHERE `trash` = 0',
    );
    await database.execute(
      'CREATE UNIQUE INDEX `index_url_title` ON `url` (`title`) WHERE `trash` = 0',
    );
  },
);
