# Database Schema

The links data is stored in SQLite through Floor: database file `keep_links_db.db`, schema version 1 (`UrlDatabase`). The entities are in `lib/core/data/database/entity/`.

## Overview

```
folder 1 ──── * url * ──── * tag
                  (via url_tag)
```

- Every link belongs to exactly one folder.
- A link can have any number of tags, and a tag can be on any number of links. The `url_tag` join table stores these links.

## Uniqueness

Each table's `id` is its primary key, so it is always unique. On top of that, the following columns are unique, enforced with unique indexes on the Floor entities:

- **url**: `url` and `title` — two links can't share the same URL or the same title.
- **folder**: `folder_name` — two folders can't have the same name.
- **tag**: `tag_name` — two tags can't have the same name.
- **url_tag**: the composite primary key (`url_id`, `tag_id`) — a tag can be attached to a link only once.

Inserting or updating a row that breaks one of these constraints throws an error, which the BLoC/Cubit catches and reports to the user. `MockUrlStore` mirrors the same rules in memory.

## Relationships (foreign keys)

| Column | References | On delete of the parent |
|---|---|---|
| `url.folder_id` | `folder.id` | **Restrict**: a folder that still has links can't be deleted. Move its links to another folder first (`deleteFolderAndMoveUrls`). |
| `url_tag.url_id` | `url.id` | **Cascade**: deleting a link deletes its tag links. |
| `url_tag.tag_id` | `tag.id` | **Cascade**: deleting a tag deletes its links to URLs. |

Floor turns on SQLite's foreign-key checks (`PRAGMA foreign_keys = ON`) whenever it opens the database. Inserting a row whose foreign key points to a missing row throws an error.

`MockUrlStore` doesn't enforce foreign keys. It relies on the stores' own checks, such as `FolderNotFoundException` and `TagNotFoundException` in `createUrl`.

## Indexes

| Index | Table (columns) | Unique | Purpose |
|---|---|---|---|
| `index_url_url` | `url` (`url`) | Yes | No duplicate URLs; fast duplicate check |
| `index_url_title` | `url` (`title`) | Yes | No duplicate titles; fast duplicate check |
| `index_url_folder_id` | `url` (`folder_id`) | No | Fast lookup of a folder's links and the foreign-key check on folder delete |
| `index_folder_folder_name` | `folder` (`folder_name`) | Yes | No duplicate folder names |
| `index_tag_tag_name` | `tag` (`tag_name`) | Yes | No duplicate tag names |
| `index_url_tag_tag_id` | `url_tag` (`tag_id`) | No | Fast lookup of a tag's links and the cascade on tag delete |

`url_tag` needs no separate index on `url_id`, because its primary key (`url_id`, `tag_id`) already starts with `url_id`.

## Tables

### url

| Column | Type | Null | Constraint | Notes |
|---|---|---|---|---|
| id | INTEGER | No | Primary Key (auto-increment) | |
| url | TEXT | No | Unique | |
| title | TEXT | No | Unique | |
| meta_image_url | TEXT | No | | |
| meta_description | TEXT | No | | |
| folder_id | INTEGER | No | Foreign Key → `folder.id` (restrict), indexed | |
| created_at | INTEGER | No | | Milliseconds since epoch |
| updated_at | INTEGER | No | | Milliseconds since epoch |
| is_favorite | INTEGER | No | | Boolean: 0 or 1 |
| preview_image_name | TEXT | Yes | | File name only (not the full path) of the user's preview image in `PreviewImageStorage`'s folder; `NULL` if the link has none |
| trash | INTEGER | No | | Boolean: 0 or 1; 1 means marked to be deleted |

### folder

| Column | Type | Null | Constraint |
|---|---|---|---|
| id | INTEGER | No | Primary Key (auto-increment) |
| folder_name | TEXT | No | Unique |

### tag

| Column | Type | Null | Constraint |
|---|---|---|---|
| id | INTEGER | No | Primary Key (auto-increment) |
| tag_name | TEXT | No | Unique |

### url_tag

| Column | Type | Null | Constraint |
|---|---|---|---|
| url_id + tag_id | | | Composite Primary Key |
| url_id | INTEGER | No | Foreign Key → `url.id` (cascade) |
| tag_id | INTEGER | No | Foreign Key → `tag.id` (cascade), indexed |
