import 'package:floor/floor.dart';

@Entity(
  tableName: 'url',
  indices: [
    Index(value: ['url'], unique: true),
    Index(value: ['title'], unique: true),
  ],
)
class Url {
  Url({
    this.id,
    required this.url,
    required this.title,
    required this.metaImageUrl,
    required this.metaDescription,
    this.folderId,
    required this.createdAt,
    required this.updatedAt,
    required this.isFavorite,
    this.previewImageName,
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
  final int? folderId;

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
    );
  }

  @override
  String toString() {
    return 'Url{id: $id, url: $url, title: $title, metaImageUrl: $metaImageUrl, metaDescription: $metaDescription, folderId: $folderId, createdAt: $createdAt, updatedAt: $updatedAt, isFavorite: $isFavorite, previewImageName: $previewImageName}';
  }
}
