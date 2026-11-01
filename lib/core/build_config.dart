import 'package:flutter/foundation.dart';

class BuildConfig {
  static bool isDevelopmentBuild = false;

  /// Returns true if the build is a developer build or a debug build.
  static bool get isDeveloperOrDebug => (isDevelopmentBuild || kDebugMode);
}
