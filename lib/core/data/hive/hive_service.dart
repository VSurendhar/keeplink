import 'package:hive_flutter/hive_flutter.dart';
import 'package:mindful_links/core/data/hive/models/app_settings.dart';

class HiveService {
  static const String settingsBoxName = 'app_settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(AppThemeAdapter());
    Hive.registerAdapter(AppLanguageAdapter());
    await Hive.openBox(settingsBoxName);
  }
}
