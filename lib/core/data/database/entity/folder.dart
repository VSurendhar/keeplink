import 'package:floor/floor.dart';

@Entity(
  tableName: 'folder',
  indices: [
    Index(value: ['folder_name'], unique: true),
  ],
)
class Folder {
  Folder({this.id, required this.folderName, this.trash = false});

  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'folder_name')
  final String folderName;

  /// Whether the user deleted this folder while a trashed URL still uses it.
  @ColumnInfo(name: 'trash')
  final bool trash;

  Folder copyWith({int? id, String? folderName, bool? trash}) {
    return Folder(
      id: id ?? this.id,
      folderName: folderName ?? this.folderName,
      trash: trash ?? this.trash,
    );
  }

  @override
  String toString() {
    return 'Folder{id: $id, folderName: $folderName, trash: $trash}';
  }
}
