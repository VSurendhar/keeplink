---
trigger: always_on
description: Keep BLoC and Cubit Events, Actions, and States in separate files with consistent naming conventions
---

# BLoC and Cubit File Structure

Keep Events, Actions, and States in separate files from their respective BLoC or Cubit implementation.

Do not define Events, Actions, or States in the same file as the BLoC or Cubit.

## Directory Structure

Organize BLoC and Cubit-related files inside their respective feature directories.

Example:

lib/
features/
settings/
bloc/
app_settings_bloc.dart
app_settings_event.dart
app_settings_state.dart
app_settings_action.dart

## Naming Conventions

Use the feature name as the prefix for Event, Action, and State class names.

Follow these naming patterns:

- BLoC: `FeatureNameBloc`
- Cubit: `FeatureNameCubit`
- Events: `FeatureNameEvent`
- Actions: `FeatureNameAction`
- States: `FeatureNameState`

## Example

For the Settings feature:

- `AppSettingsBloc` → `app_settings_bloc.dart`
- `AppSettingsEvent` → `app_settings_event.dart`
- `AppSettingsAction` → `app_settings_action.dart`
- `AppSettingsState` → `app_settings_state.dart`

For a Payment feature:

- `PaymentBloc` → `payment_bloc.dart`
- `PaymentEvent` → `payment_event.dart`
- `PaymentAction` → `payment_action.dart`
- `PaymentState` → `payment_state.dart`

## Important

1. Keep Events, Actions, and States in separate files.
2. Follow the class-to-file naming convention.
3. Do not mix unrelated feature Events, Actions, or States.
4. Follow the existing project directory structure when creating new BLoC or Cubit files.
5. Inspect existing implementations before introducing a new structure.