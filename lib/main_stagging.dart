import 'package:flutter/widgets.dart';
import 'package:mindful_links/core/build_config.dart';

import 'bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BuildConfig.isDevelopmentBuild = false;
  bootstrap();
}
