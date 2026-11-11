---
trigger: always_on
description: Identify duplicate logic, reuse existing implementations, and refactor common code into reusable functions
---

# Code Reusability and Refactoring

Before implementing a new function or feature, inspect the existing codebase for similar implementations and reusable logic.

Avoid duplicating existing logic or repeating the same sequence of operations across multiple functions.

## Guidelines

1. Search for existing functions, methods, utilities, and implementations that perform similar operations.
2. Identify common logic between existing and newly requested functionality.
3. If multiple functions share the same core logic, consider extracting it into a separate reusable function or method.
4. Reuse existing helper functions instead of rewriting their logic.
5. Keep function responsibilities focused and avoid unnecessarily large functions.
6. When extracting common logic, pass varying values as parameters rather than duplicating the implementation.
7. Refactor existing code when necessary to eliminate duplication, while preserving its existing behaviour.
8. Avoid creating abstractions for code that is unlikely to be reused or when extraction makes the implementation harder to understand.

## Before Completing Implementation

Verify that:

- No unnecessary duplicate functions or methods were introduced.
- Common logic is reused wherever appropriate.
- Repeated code has been extracted when doing so improves maintainability.
- Existing functionality remains unchanged unless explicitly requested.

## Important

Do not focus only on making the requested functionality work.

Also consider whether the implementation can be made more reusable, maintainable, and concise by identifying opportunities for refactoring.

Prefer meaningful code reuse over blindly reducing the number of lines.