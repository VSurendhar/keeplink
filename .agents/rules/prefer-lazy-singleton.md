---
trigger: always_on
description: Prefer @lazySingleton over @singleton for configs and stores
---

# Prefer `@lazySingleton` for configs and stores

For injectable configs, stores, and similar app-wide dependencies, prefer `@lazySingleton` over `@singleton`.

`@lazySingleton` creates the instance on first use instead of at app start, which keeps startup lighter and matches existing project patterns (`*Config`, `*Store`, services).

```dart
// BAD
@singleton
class MyFeatureConfig {}

// GOOD
@lazySingleton
class MyFeatureConfig {}
```
