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
