# Database Schema

## Uniqueness

Each table's `id` is its primary key, so it is always unique. On top of that, the following columns are unique, enforced with unique indexes on the Floor entities:

- **url**: `url` and `title` — two links can't share the same URL or the same title.
- **folder**: `folder_name` — two folders can't have the same name.
- **tag**: `tag_name` — two tags can't have the same name.
- **url_tag**: the composite primary key (`url_id`, `tag_id`) — a tag can be attached to a link only once.

Inserting or updating a row that breaks one of these constraints throws an error, which the BLoC/Cubit catches and reports to the user. `MockUrlStore` mirrors the same rules in memory.

## Tables

### url

| Column | Constraint |
|---|---|
| id | Primary Key |
| url | Unique |
| title | Unique |
| meta_image_url | |
| meta_description | |
| folder_id | Foreign Key |
| created_at | |
| updated_at | |
| is_favorite | |

### folder

| Column | Constraint |
|---|---|
| id | Primary Key |
| folder_name | Unique |

### tag

| Column | Constraint |
|---|---|
| id | Primary Key |
| tag_name | Unique |

### url_tag

| Column | Constraint |
|---|---|
| url_id + tag_id | Composite Key |
| url_id | |
| tag_id | |
