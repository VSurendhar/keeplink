---
trigger: always_on
description: Use power-of-2 dimensions wherever possible, prioritizing power-of-2 values and then even numbers
---

# Dimension Guidelines

When defining UI dimensions such as width, height, padding, margin, spacing, radius, and icon sizes, follow these priorities:

## Priority 1: Power of 2

Always prefer power-of-2 values wherever reasonably possible.

Examples:
- 2
- 4
- 8
- 16
- 32

## Priority 2: Even Numbers

If a suitable power-of-2 value is not practical, prefer an even number.

Examples:
- 6
- 10
- 12
- 14
- 18
- 20
- 24

## Preferred Dimensions

Try to use these values most of the time:

- 8
- 16

Use 8 and 16 as the primary spacing and sizing values whenever appropriate.

## Guidelines

1. Prefer power-of-2 dimensions over other values.
2. If a power-of-2 value does not suit the design, use an even number.
3. Avoid odd-numbered dimensions unless there is a clear design requirement.
4. Reuse existing dimension constants instead of introducing duplicate values.
5. Maintain visual consistency across the application.
6. Do not compromise the intended UI design or responsiveness just to satisfy these numerical preferences.
7. Follow existing project conventions when they provide a specific design-system value.

## Examples

GOOD:
```dart
const EdgeInsets.all(8);
const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
const SizedBox(height: 16);
const BorderRadius.all(Radius.circular(8));