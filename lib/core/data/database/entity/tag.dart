import 'package:floor/floor.dart';

@Entity(
  tableName: 'tag',
  indices: [
    Index(value: ['tag_name'], unique: true),
  ],
)
class Tag {
  Tag({this.id, required this.tagName, this.trash = false});

  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: "tag_name")
  final String tagName;

  /// Whether the user deleted this tag while a trashed URL still uses it.
  @ColumnInfo(name: 'trash')
  final bool trash;

  Tag copyWith({int? id, String? tagName, bool? trash}) {
    return Tag(
      id: id ?? this.id,
      tagName: tagName ?? this.tagName,
      trash: trash ?? this.trash,
    );
  }

  @override
  String toString() {
    return 'Tag{id: $id, tagName: $tagName, trash: $trash}';
  }
}
