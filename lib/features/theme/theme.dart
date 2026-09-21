import 'package:flutter/material.dart';

class MindfulLinksTheme {
  static const Color primary = Color(0xFFFFB38E);
  static const Color primaryDark = Color(0xFFE28A63);

  static const Color secondary = Color(0xFFFBF2ED);
  static const Color secondaryLight = Color(0xFFFFF8F5);

  static const Color textPrimary = Color(0xFF2D2926);
  static const Color textSecondary = Color(0xFF362F2D);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,

      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: Colors.white,

        secondary: secondary,
        onSecondary: textPrimary,

        error: Colors.red,
        onError: Colors.white,

        surface: secondaryLight,
        onSurface: textPrimary,
      ),

      scaffoldBackgroundColor: secondaryLight,
    );
  }
}
