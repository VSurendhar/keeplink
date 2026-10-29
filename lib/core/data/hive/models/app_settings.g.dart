// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppThemeAdapter extends TypeAdapter<AppTheme> {
  @override
  final int typeId = 1;

  @override
  AppTheme read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AppTheme.light;
      case 1:
        return AppTheme.dark;
      default:
        return AppTheme.light;
    }
  }

  @override
  void write(BinaryWriter writer, AppTheme obj) {
    switch (obj) {
      case AppTheme.light:
        writer.writeByte(0);
        break;
      case AppTheme.dark:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppThemeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppLanguageAdapter extends TypeAdapter<AppLanguage> {
  @override
  final int typeId = 2;

  @override
  AppLanguage read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AppLanguage.englishUs;
      case 1:
        return AppLanguage.englishUK;
      case 2:
        return AppLanguage.spanish;
      case 3:
        return AppLanguage.french;
      case 4:
        return AppLanguage.german;
      case 5:
        return AppLanguage.japanese;
      default:
        return AppLanguage.englishUs;
    }
  }

  @override
  void write(BinaryWriter writer, AppLanguage obj) {
    switch (obj) {
      case AppLanguage.englishUs:
        writer.writeByte(0);
        break;
      case AppLanguage.englishUK:
        writer.writeByte(1);
        break;
      case AppLanguage.spanish:
        writer.writeByte(2);
        break;
      case AppLanguage.french:
        writer.writeByte(3);
        break;
      case AppLanguage.german:
        writer.writeByte(4);
        break;
      case AppLanguage.japanese:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppLanguageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
