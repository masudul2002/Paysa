import 'package:flutter/material.dart';

final class AppTheme {
  const AppTheme._();

  static const _seedColor = Color(0xFF0F766E);

  static ThemeData light(ColorScheme? dynamicScheme) {
    return _base(
      colorScheme: dynamicScheme ?? ColorScheme.fromSeed(seedColor: _seedColor),
    );
  }

  static ThemeData dark(ColorScheme? dynamicScheme) {
    return _base(
      colorScheme:
          dynamicScheme ??
          ColorScheme.fromSeed(
            seedColor: _seedColor,
            brightness: Brightness.dark,
          ),
    );
  }

  static ThemeData _base({required ColorScheme colorScheme}) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
    );
  }
}
