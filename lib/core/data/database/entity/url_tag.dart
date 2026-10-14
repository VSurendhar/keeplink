import 'package:floor/floor.dart';

@Entity(tableName: "url_tag", primaryKeys: ['url_id', 'tag_id'])
class UrlTag {
  UrlTag({required this.urlId, required this.tagId});

  @ColumnInfo(name: 'url_id')
  final int urlId;

  @ColumnInfo(name: 'tag_id')
  final int tagId;
}
