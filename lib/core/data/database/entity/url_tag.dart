import 'package:floor/floor.dart';
import 'package:mindful_links/core/data/database/entity/tag.dart';
import 'package:mindful_links/core/data/database/entity/url.dart';

@Entity(
  tableName: 'url_tag',
  primaryKeys: ['url_id', 'tag_id'],
  foreignKeys: [
    // Deleting a URL removes its tag links.
    ForeignKey(
      childColumns: ['url_id'],
      parentColumns: ['id'],
      entity: Url,
      onDelete: ForeignKeyAction.cascade,
    ),
    // Deleting a tag removes its URL links.
    ForeignKey(
      childColumns: ['tag_id'],
      parentColumns: ['id'],
      entity: Tag,
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
  indices: [
    // The primary key already covers lookups by url_id; this covers tag_id.
    Index(value: ['tag_id']),
  ],
)
class UrlTag {
  UrlTag({required this.urlId, required this.tagId});

  @ColumnInfo(name: 'url_id')
  final int urlId;

  @ColumnInfo(name: 'tag_id')
  final int tagId;

  @override
  String toString() {
    return 'UrlTag{urlId: $urlId, tagId: $tagId}';
  }
}
