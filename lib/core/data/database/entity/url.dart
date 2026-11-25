import 'package:floor/floor.dart';
import 'package:keep_links/core/data/database/entity/folder.dart';

@Entity(
  tableName: 'url',
  foreignKeys: [
    // A folder can't be deleted while it still has URLs; move them first.
    ForeignKey(
      childColumns: ['folder_id'],
      parentColumns: ['id'],
      entity: Folder,
      onDelete: ForeignKeyAction.restrict,
    ),
  ],
  indices: [
    // `url` and `title` are unique among saved URLs only. Floor can't declare
    // partial indexes, so `urlDatabaseCallback` creates them.
    // Speeds up finding a folder's URLs and the foreign-key check when a
    // folder is deleted.
    Index(value: ['folder_id']),
  ],
)
class Url {
  Url({
    this.id,
    required this.url,
    required this.title,
    required this.metaImageUrl,
    required this.metaDescription,
    required this.folderId,
    required this.createdAt,
    required this.updatedAt,
    required this.isFavorite,
    this.previewImageName,
    this.trash = false,
  });

  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String url;
  final String title;

  @ColumnInfo(name: 'meta_image_url')
  final String metaImageUrl;

  @ColumnInfo(name: 'meta_description')
  final String metaDescription;

  @ColumnInfo(name: 'folder_id')
  final int folderId;

  @ColumnInfo(name: 'created_at')
  final int createdAt;

  @ColumnInfo(name: 'updated_at')
  final int updatedAt;

  @ColumnInfo(name: 'is_favorite')
  final bool isFavorite;

  /// File name (not the full path) of the user's preview image, stored in
  /// `PreviewImageStorage`'s folder, or `null` if the link has none.
  @ColumnInfo(name: 'preview_image_name')
  final String? previewImageName;

  /// Whether this URL is marked to be deleted.
  @ColumnInfo(name: 'trash')
  final bool trash;

  Url copyWith({
    int? id,
    String? url,
    String? title,
    String? metaImageUrl,
    String? metaDescription,
    int? folderId,
    int? createdAt,
    int? updatedAt,
    bool? isFavorite,
    String? previewImageName,
    bool? trash,
  }) {
    return Url(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      metaImageUrl: metaImageUrl ?? this.metaImageUrl,
      metaDescription: metaDescription ?? this.metaDescription,
      folderId: folderId ?? this.folderId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      previewImageName: previewImageName ?? this.previewImageName,
      trash: trash ?? this.trash,
    );
  }

  @override
  String toString() {
    return 'Url{id: $id, url: $url, title: $title, metaImageUrl: $metaImageUrl, metaDescription: $metaDescription, folderId: $folderId, createdAt: $createdAt, updatedAt: $updatedAt, isFavorite: $isFavorite, previewImageName: $previewImageName, trash: $trash}';
  }
}
