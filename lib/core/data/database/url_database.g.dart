// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $UrlDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $UrlDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $UrlDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<UrlDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorUrlDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $UrlDatabaseBuilderContract databaseBuilder(String name) =>
      _$UrlDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $UrlDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$UrlDatabaseBuilder(null);
}

class _$UrlDatabaseBuilder implements $UrlDatabaseBuilderContract {
  _$UrlDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $UrlDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $UrlDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<UrlDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$UrlDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$UrlDatabase extends UrlDatabase {
  _$UrlDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  UrlDao? _urlDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `url` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `url` TEXT NOT NULL, `title` TEXT NOT NULL, `meta_image_url` TEXT NOT NULL, `meta_description` TEXT NOT NULL, `folder_id` INTEGER NOT NULL, `created_at` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, `is_favorite` INTEGER NOT NULL, `preview_image_name` TEXT, FOREIGN KEY (`folder_id`) REFERENCES `folder` (`id`) ON UPDATE NO ACTION ON DELETE RESTRICT)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `url_tag` (`url_id` INTEGER NOT NULL, `tag_id` INTEGER NOT NULL, FOREIGN KEY (`url_id`) REFERENCES `url` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, FOREIGN KEY (`tag_id`) REFERENCES `tag` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, PRIMARY KEY (`url_id`, `tag_id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `folder` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `folder_name` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `tag` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `tag_name` TEXT NOT NULL)');
        await database
            .execute('CREATE UNIQUE INDEX `index_url_url` ON `url` (`url`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_url_title` ON `url` (`title`)');
        await database.execute(
            'CREATE INDEX `index_url_folder_id` ON `url` (`folder_id`)');
        await database.execute(
            'CREATE INDEX `index_url_tag_tag_id` ON `url_tag` (`tag_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_folder_folder_name` ON `folder` (`folder_name`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_tag_tag_name` ON `tag` (`tag_name`)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  UrlDao get urlDao {
    return _urlDaoInstance ??= _$UrlDao(database, changeListener);
  }
}

class _$UrlDao extends UrlDao {
  _$UrlDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _urlInsertionAdapter = InsertionAdapter(
            database,
            'url',
            (Url item) => <String, Object?>{
                  'id': item.id,
                  'url': item.url,
                  'title': item.title,
                  'meta_image_url': item.metaImageUrl,
                  'meta_description': item.metaDescription,
                  'folder_id': item.folderId,
                  'created_at': item.createdAt,
                  'updated_at': item.updatedAt,
                  'is_favorite': item.isFavorite ? 1 : 0,
                  'preview_image_name': item.previewImageName
                },
            changeListener),
        _folderInsertionAdapter = InsertionAdapter(
            database,
            'folder',
            (Folder item) => <String, Object?>{
                  'id': item.id,
                  'folder_name': item.folderName
                },
            changeListener),
        _tagInsertionAdapter = InsertionAdapter(
            database,
            'tag',
            (Tag item) =>
                <String, Object?>{'id': item.id, 'tag_name': item.tagName},
            changeListener),
        _urlTagInsertionAdapter = InsertionAdapter(
            database,
            'url_tag',
            (UrlTag item) =>
                <String, Object?>{'url_id': item.urlId, 'tag_id': item.tagId},
            changeListener),
        _urlUpdateAdapter = UpdateAdapter(
            database,
            'url',
            ['id'],
            (Url item) => <String, Object?>{
                  'id': item.id,
                  'url': item.url,
                  'title': item.title,
                  'meta_image_url': item.metaImageUrl,
                  'meta_description': item.metaDescription,
                  'folder_id': item.folderId,
                  'created_at': item.createdAt,
                  'updated_at': item.updatedAt,
                  'is_favorite': item.isFavorite ? 1 : 0,
                  'preview_image_name': item.previewImageName
                },
            changeListener),
        _folderDeletionAdapter = DeletionAdapter(
            database,
            'folder',
            ['id'],
            (Folder item) => <String, Object?>{
                  'id': item.id,
                  'folder_name': item.folderName
                },
            changeListener),
        _urlTagDeletionAdapter = DeletionAdapter(
            database,
            'url_tag',
            ['url_id', 'tag_id'],
            (UrlTag item) =>
                <String, Object?>{'url_id': item.urlId, 'tag_id': item.tagId},
            changeListener),
        _tagDeletionAdapter = DeletionAdapter(
            database,
            'tag',
            ['id'],
            (Tag item) =>
                <String, Object?>{'id': item.id, 'tag_name': item.tagName},
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Url> _urlInsertionAdapter;

  final InsertionAdapter<Folder> _folderInsertionAdapter;

  final InsertionAdapter<Tag> _tagInsertionAdapter;

  final InsertionAdapter<UrlTag> _urlTagInsertionAdapter;

  final UpdateAdapter<Url> _urlUpdateAdapter;

  final DeletionAdapter<Folder> _folderDeletionAdapter;

  final DeletionAdapter<UrlTag> _urlTagDeletionAdapter;

  final DeletionAdapter<Tag> _tagDeletionAdapter;

  @override
  Stream<List<Url>> findAllUrl() {
    return _queryAdapter.queryListStream('SELECT * FROM url',
        mapper: (Map<String, Object?> row) => Url(
            id: row['id'] as int?,
            url: row['url'] as String,
            title: row['title'] as String,
            metaImageUrl: row['meta_image_url'] as String,
            metaDescription: row['meta_description'] as String,
            folderId: row['folder_id'] as int,
            createdAt: row['created_at'] as int,
            updatedAt: row['updated_at'] as int,
            isFavorite: (row['is_favorite'] as int) != 0,
            previewImageName: row['preview_image_name'] as String?),
        queryableName: 'url',
        isView: false);
  }

  @override
  Future<Folder?> findFolderForUrlId(int id) async {
    return _queryAdapter.query(
        'SELECT * FROM folder f where f.id = (SELECT folder_id FROM url u WHERE u.id = ?1)',
        mapper: (Map<String, Object?> row) => Folder(id: row['id'] as int?, folderName: row['folder_name'] as String),
        arguments: [id]);
  }

  @override
  Stream<List<UrlTag>> findAllUrlTags() {
    return _queryAdapter.queryListStream('SELECT * FROM url_tag',
        mapper: (Map<String, Object?> row) =>
            UrlTag(urlId: row['url_id'] as int, tagId: row['tag_id'] as int),
        queryableName: 'url_tag',
        isView: false);
  }

  @override
  Stream<List<Tag>> findAllTags() {
    return _queryAdapter.queryListStream('SELECT * FROM tag',
        mapper: (Map<String, Object?> row) =>
            Tag(id: row['id'] as int?, tagName: row['tag_name'] as String),
        queryableName: 'tag',
        isView: false);
  }

  @override
  Stream<List<Folder>> findAllFolders() {
    return _queryAdapter.queryListStream('SELECT * FROM folder',
        mapper: (Map<String, Object?> row) => Folder(
            id: row['id'] as int?, folderName: row['folder_name'] as String),
        queryableName: 'folder',
        isView: false);
  }

  @override
  Future<List<int>> findAllUrlFolderIds() async {
    return _queryAdapter.queryList('SELECT folder_id FROM url',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<List<int>> findAllUrlTagIds() async {
    return _queryAdapter.queryList('SELECT tag_id FROM url_tag',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<List<Url>> findUrlsByFolderId(int folderId) async {
    return _queryAdapter.queryList('SELECT * FROM url WHERE folder_id = ?1',
        mapper: (Map<String, Object?> row) => Url(
            id: row['id'] as int?,
            url: row['url'] as String,
            title: row['title'] as String,
            metaImageUrl: row['meta_image_url'] as String,
            metaDescription: row['meta_description'] as String,
            folderId: row['folder_id'] as int,
            createdAt: row['created_at'] as int,
            updatedAt: row['updated_at'] as int,
            isFavorite: (row['is_favorite'] as int) != 0,
            previewImageName: row['preview_image_name'] as String?),
        arguments: [folderId]);
  }

  @override
  Future<List<UrlTag>> findUrlTagsByTagId(int tagId) async {
    return _queryAdapter.queryList('SELECT * FROM url_tag WHERE tag_id = ?1',
        mapper: (Map<String, Object?> row) =>
            UrlTag(urlId: row['url_id'] as int, tagId: row['tag_id'] as int),
        arguments: [tagId]);
  }

  @override
  Future<void> deleteAllUrlTags() async {
    await _queryAdapter.queryNoReturn('DELETE FROM url_tag');
  }

  @override
  Future<void> deleteAllUrls() async {
    await _queryAdapter.queryNoReturn('DELETE FROM url');
  }

  @override
  Future<void> deleteAllTags() async {
    await _queryAdapter.queryNoReturn('DELETE FROM tag');
  }

  @override
  Future<void> deleteAllFolders() async {
    await _queryAdapter.queryNoReturn('DELETE FROM folder');
  }

  @override
  Future<Folder?> findFolderById(int id) async {
    return _queryAdapter.query('SELECT * FROM folder WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Folder(
            id: row['id'] as int?, folderName: row['folder_name'] as String),
        arguments: [id]);
  }

  @override
  Future<Folder?> findFolderByName(String folderName) async {
    return _queryAdapter.query('SELECT * FROM folder WHERE folder_name = ?1',
        mapper: (Map<String, Object?> row) => Folder(
            id: row['id'] as int?, folderName: row['folder_name'] as String),
        arguments: [folderName]);
  }

  @override
  Future<Url?> findUrlById(int id) async {
    return _queryAdapter.query('SELECT * FROM url WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Url(
            id: row['id'] as int?,
            url: row['url'] as String,
            title: row['title'] as String,
            metaImageUrl: row['meta_image_url'] as String,
            metaDescription: row['meta_description'] as String,
            folderId: row['folder_id'] as int,
            createdAt: row['created_at'] as int,
            updatedAt: row['updated_at'] as int,
            isFavorite: (row['is_favorite'] as int) != 0,
            previewImageName: row['preview_image_name'] as String?),
        arguments: [id]);
  }

  @override
  Future<Url?> findUrlByUrlString(String url) async {
    return _queryAdapter.query('SELECT * FROM url WHERE url = ?1',
        mapper: (Map<String, Object?> row) => Url(
            id: row['id'] as int?,
            url: row['url'] as String,
            title: row['title'] as String,
            metaImageUrl: row['meta_image_url'] as String,
            metaDescription: row['meta_description'] as String,
            folderId: row['folder_id'] as int,
            createdAt: row['created_at'] as int,
            updatedAt: row['updated_at'] as int,
            isFavorite: (row['is_favorite'] as int) != 0,
            previewImageName: row['preview_image_name'] as String?),
        arguments: [url]);
  }

  @override
  Future<Url?> findUrlByTitle(String title) async {
    return _queryAdapter.query('SELECT * FROM url WHERE title = ?1',
        mapper: (Map<String, Object?> row) => Url(
            id: row['id'] as int?,
            url: row['url'] as String,
            title: row['title'] as String,
            metaImageUrl: row['meta_image_url'] as String,
            metaDescription: row['meta_description'] as String,
            folderId: row['folder_id'] as int,
            createdAt: row['created_at'] as int,
            updatedAt: row['updated_at'] as int,
            isFavorite: (row['is_favorite'] as int) != 0,
            previewImageName: row['preview_image_name'] as String?),
        arguments: [title]);
  }

  @override
  Future<Tag?> findTagById(int id) async {
    return _queryAdapter.query('SELECT * FROM tag WHERE id = ?1',
        mapper: (Map<String, Object?> row) =>
            Tag(id: row['id'] as int?, tagName: row['tag_name'] as String),
        arguments: [id]);
  }

  @override
  Future<Tag?> findTagByName(String tagName) async {
    return _queryAdapter.query('SELECT * FROM tag WHERE tag_name = ?1',
        mapper: (Map<String, Object?> row) =>
            Tag(id: row['id'] as int?, tagName: row['tag_name'] as String),
        arguments: [tagName]);
  }

  @override
  Future<UrlTag?> findUrlTag(
    int urlId,
    int tagId,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM url_tag WHERE url_id = ?1 AND tag_id = ?2',
        mapper: (Map<String, Object?> row) =>
            UrlTag(urlId: row['url_id'] as int, tagId: row['tag_id'] as int),
        arguments: [urlId, tagId]);
  }

  @override
  Future<int> insertUrl(Url url) {
    return _urlInsertionAdapter.insertAndReturnId(
        url, OnConflictStrategy.abort);
  }

  @override
  Future<int> insertFolder(Folder folder) {
    return _folderInsertionAdapter.insertAndReturnId(
        folder, OnConflictStrategy.abort);
  }

  @override
  Future<int> insertTag(Tag tag) {
    return _tagInsertionAdapter.insertAndReturnId(
        tag, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertUrlTag(UrlTag urlTag) async {
    await _urlTagInsertionAdapter.insert(urlTag, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateUrls(List<Url> urls) async {
    await _urlUpdateAdapter.updateList(urls, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteFolder(Folder folder) async {
    await _folderDeletionAdapter.delete(folder);
  }

  @override
  Future<void> deleteUrlTags(List<UrlTag> urlTags) async {
    await _urlTagDeletionAdapter.deleteList(urlTags);
  }

  @override
  Future<void> deleteTag(Tag tag) async {
    await _tagDeletionAdapter.delete(tag);
  }

  @override
  Future<void> clearAll() async {
    if (database is sqflite.Transaction) {
      await super.clearAll();
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$UrlDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.urlDao.clearAll();
      });
    }
  }

  @override
  Future<int> createUrl(
    Url url,
    List<int> tagIds,
  ) async {
    if (database is sqflite.Transaction) {
      return super.createUrl(url, tagIds);
    } else {
      return (database as sqflite.Database)
          .transaction<int>((transaction) async {
        final transactionDatabase = _$UrlDatabase(changeListener)
          ..database = transaction;
        return transactionDatabase.urlDao.createUrl(url, tagIds);
      });
    }
  }

  @override
  Future<void> deleteFolderAndMoveUrls(
    int sourceFolderId,
    int targetFolderId,
  ) async {
    if (database is sqflite.Transaction) {
      await super.deleteFolderAndMoveUrls(sourceFolderId, targetFolderId);
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$UrlDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.urlDao
            .deleteFolderAndMoveUrls(sourceFolderId, targetFolderId);
      });
    }
  }

  @override
  Future<void> deleteTagAndUrlTags(int tagId) async {
    if (database is sqflite.Transaction) {
      await super.deleteTagAndUrlTags(tagId);
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$UrlDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.urlDao.deleteTagAndUrlTags(tagId);
      });
    }
  }
}
