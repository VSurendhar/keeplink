---
trigger: always_on
description: Dart class names and file names must follow matching naming conventions
---

# Class and File Naming Convention

The primary class name in a Dart file must match the file name using Dart's snake_case convention.

## Rules

1. Convert the class name from PascalCase to snake_case for the file name.
2. Keep the file name and primary class name consistent.
3. Apply this convention to BLoCs, Cubits, services, repositories, models, and other Dart classes.

## Examples

**GOOD:**

Class: `AppSettingsBloc`
File: `app_settings_bloc.dart`

Class: `UserRepository`
File: `user_repository.dart`

Class: `PaymentService`
File: `payment_service.dart`

**BAD:**

Class: `AppSettingsBloc`
File: `settings_bloc.dart`

Class: `UserRepository`
File: `repository.dart`