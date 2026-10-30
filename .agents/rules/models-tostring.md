---
description: Every Dart model must override toString()
alwaysApply: true
---

# Models must override `toString()`

Every handwritten Dart model must override `toString()` and include all instance fields.

```dart
@override
String toString() {
  return 'MyModel{field: $field}';
}
```
