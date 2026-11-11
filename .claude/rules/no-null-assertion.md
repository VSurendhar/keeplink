---
trigger: always_on
description: Never use the null-assertion operator (!); use a local null-check
---

# No null-assertion operator (`!`)

Never use the null-assertion operator (`!`) in handwritten Dart code.

Assign the value to a local variable and perform an explicit null check instead.

### Example

**BAD:**

```dart
doSomething(response.badge!);