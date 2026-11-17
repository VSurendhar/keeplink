import 'package:floor/floor.dart';

@Entity(
  tableName: 'folder',
  indices: [
    Index(value: ['folder_name'], unique: true),
  ],
)
class Folder {
  Folder({this.id, required this.folderName});

  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'folder_name')
  final String folderName;
}
