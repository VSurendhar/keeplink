---
description: Before adding code, grep existing patterns and match conventions
alwaysApply: true
---

# Follow existing patterns

Before adding code — grep existing patterns and match types/conventions (unless the author asked to override the style).

## Checklist

1. Find a reference implementation nearby (same feature / sibling model).
2. Match wire types to project convention (colors as `int`, enums, nullability).
3. Re-read parent/child boundaries — layout in parent, values as params to children.
4. If your approach differs from every similar file, you're probably wrong.

```dart
// BAD — invent hex string colors for new API fields
@JsonKey(name: 'icon_color')
final String? iconColor;

// GOOD — match existing API color pattern
@JsonKey(name: 'icon_color')
final int? iconColor;
// UI: Color(option.iconColor)
```
