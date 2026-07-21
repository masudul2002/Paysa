import 'package:flutter/material.dart';

import 'design_tokens.dart';

final class AppTheme {
  const AppTheme._();

  static const _seedColor = Color(0xFF0F766E);

  static ThemeData light([ColorScheme? ds]) {
    final cs = ds ?? ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.light);
    return _build(cs);
  }

  static ThemeData dark([ColorScheme? ds]) {
    final cs = ds ?? ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.dark);
    return _build(cs);
  }

  static ThemeData _build(ColorScheme cs) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surface,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: DesignTokens.elevationAppBar,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(DesignTokens.minTouchSize),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMd)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(DesignTokens.minTouchSize),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMd)),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: DesignTokens.elevationCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMd)),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMd)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusFull)),
      ),
    );
  }
}

// Extension on DesignTokens for the missing 14 value
extension on DesignTokens {
  static const double space14 = 14.0;
}
