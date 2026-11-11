---
trigger: always_on
description: Never edit generated files (*.g.dart, injection.config.dart)
---

# Never edit generated files

- Do **not** manually edit generated files, including:
  - `*.g.dart`
  - `injection.config.dart`
  - other generated files (e.g. `*.freezed.dart`, `*.gr.dart`).

- After changing the owning source, regenerate using:

```bash
dart run build_runner build --delete-conflicting-outputs
```
