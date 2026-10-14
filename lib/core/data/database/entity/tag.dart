import 'package:floor/floor.dart';

@Entity(tableName: "tag")
class Tag {
  Tag({this.id, required this.tagName});

  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: "tag_name")
  final String tagName;
}
