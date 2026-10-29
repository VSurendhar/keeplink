import 'package:hive_flutter/adapters.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 1)
enum AppTheme {
  @HiveField(0)
  light,
  @HiveField(1)
  dark,
}

@HiveType(typeId: 2)
enum AppLanguage {
  @HiveField(0)
  englishUs("English (US)"),
  @HiveField(1)
  englishUK("English (UK)"),
  @HiveField(2)
  spanish("Spanish"),
  @HiveField(3)
  french("French"),
  @HiveField(4)
  german("German"),
  @HiveField(5)
  japanese("Japanese");

  final String value;

  const AppLanguage(this.value);
}
