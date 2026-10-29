import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:mindful_links/core/data/hive/constant.dart';
import 'package:mindful_links/core/data/hive/hive_service.dart';
import 'package:mindful_links/core/data/hive/models/app_settings.dart';

@lazySingleton
class SettingsService {
  Box get _box => Hive.box(HiveService.settingsBoxName);

  Future<void> saveAppTheme(AppTheme appTheme) async {
    await _box.put(SettingsKeys.appTheme, appTheme);
  }

  Future<void> saveLanguage(AppLanguage language) async {
    await _box.put(SettingsKeys.appLanguage, language);
  }

  Future<void> saveTrashRetention(int period) async {
    await _box.put(SettingsKeys.trashRetention, period);
  }

  Future<void> saveOnboardingCompleted(bool value) async {
    await _box.put(SettingsKeys.onboardingCompleted, value);
  }

  bool get onboardingCompleted =>
      _box.get(SettingsKeys.onboardingCompleted, defaultValue: false);

  AppLanguage get appLanguage =>
      _box.get(SettingsKeys.appLanguage, defaultValue: AppLanguage.englishUs);

  int get trashRetention =>
      _box.get(SettingsKeys.trashRetention, defaultValue: 10);

  AppTheme get appTheme =>
      _box.get(SettingsKeys.appTheme, defaultValue: AppTheme.light);

  // Clear settings if needed
  Future<void> clearAll() async {
    await _box.clear();
  }
}
