import 'package:floor/floor.dart';

@Entity(
  tableName: 'tag',
  indices: [
    Index(value: ['tag_name'], unique: true),
  ],
)
class Tag {
  Tag({this.id, required this.tagName});

  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: "tag_name")
  final String tagName;
}
