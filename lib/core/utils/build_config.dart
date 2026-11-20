import 'package:flutter/foundation.dart';

class BuildConfig {
  static bool isDevelopmentBuild = false;

  /// Mixpanel project token, injected at build time from `secrets.json` via
  /// `--dart-define-from-file=secrets.json`. Empty when the flag is omitted.
  static const String mixpanelToken = String.fromEnvironment('MIXPANEL_TOKEN');

  /// Returns true if the build is a developer build or a debug build.
  static bool get isDeveloperOrDebug => (isDevelopmentBuild || kDebugMode);
}
