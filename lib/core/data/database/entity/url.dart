import 'package:floor/floor.dart';

@Entity(tableName: "url")
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
    );
  }
}
