import 'package:flutter/material.dart';

/// Design tokens centralised for the Paysa app shell.
/// Use these tokens instead of hardcoding repeated values in widgets.
final class DesignTokens {
  const DesignTokens._();

  // Colors - keep minimal; AppTheme uses ColorScheme but these are helpers
  static const Color brand = Color(0xFF0F766E);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  // Spacing (in logical pixels)
  static const double spacingXxs = 4.0;
  static const double spacingXs = 8.0;
  static const double spacingSm = 12.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // Border radius
  static const BorderRadiusGeometry radiusSm = BorderRadius.all(
    Radius.circular(8),
  );
  static const BorderRadiusGeometry radiusMd = BorderRadius.all(
    Radius.circular(12),
  );
  static const BorderRadiusGeometry radiusLg = BorderRadius.all(
    Radius.circular(16),
  );

  // Elevations
  static const double elevationCard = 2.0;
  static const double elevationAppBar = 0.0;

  // Animation durations
  static const Duration motionShort = Duration(milliseconds: 300);
  static const Duration motionMedium = Duration(milliseconds: 500);
  static const Duration motionLong = Duration(milliseconds: 800);

  // Minimum tap target
  static const double minTouchSize = 48.0;
}
