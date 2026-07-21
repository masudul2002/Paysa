import 'package:flutter/material.dart';

/// Complete design tokens for the Paysa design system.
///
/// Every visual value in the app comes from here.
/// Never hardcode spacing, radius, elevation, or duration in widgets.
final class DesignTokens {
  const DesignTokens._();

  // ---------------------------------------------------------------------------
  // Semantic colors
  // ---------------------------------------------------------------------------
  static const Color brand = Color(0xFF0F766E);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);
  static const Color neutral = Color(0xFF6B7280);

  // Finance colors
  static const Color income = Color(0xFF16A34A);
  static const Color expense = Color(0xFFDC2626);
  static const Color pending = Color(0xFFD97706);
  static const Color receivable = Color(0xFF16A34A);
  static const Color payable = Color(0xFFDC2626);

  // ---------------------------------------------------------------------------
  // Spacing scale (8dp grid)
  // ---------------------------------------------------------------------------
  static const double space0 = 0.0;
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;

  // Legacy aliases (for gradual migration)
  static const double spacingXxs = space4;
  static const double spacingXs = space8;
  static const double spacingSm = space12;
  static const double spacingMd = space16;
  static const double spacingLg = space24;
  static const double spacingXl = space32;

  // ---------------------------------------------------------------------------
  // Border radius
  // ---------------------------------------------------------------------------
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // ---------------------------------------------------------------------------
  // Elevation
  // ---------------------------------------------------------------------------
  static const double elevationNone = 0.0;
  static const double elevationCard = 2.0;
  static const double elevationAppBar = 0.0;
  static const double elevationModal = 8.0;

  // ---------------------------------------------------------------------------
  // Animation durations
  // ---------------------------------------------------------------------------
  static const Duration durationInstant = Duration(milliseconds: 100);
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration motionShort = Duration(milliseconds: 300);
  static const Duration motionMedium = Duration(milliseconds: 500);
  static const Duration motionLong = Duration(milliseconds: 800);

  // ---------------------------------------------------------------------------
  // Touch targets
  // ---------------------------------------------------------------------------
  static const double minTouchSize = 48.0;
  static const double iconButtonSize = 48.0;

  // ---------------------------------------------------------------------------
  // Typography sizes (for reference — actual styles come from Material 3 theme)
  // ---------------------------------------------------------------------------
  static const double textXs = 10.0;
  static const double textSm = 12.0;
  static const double textMd = 14.0;
  static const double textLg = 16.0;
  static const double textXl = 20.0;
  static const double textDisplay = 28.0;

  // ---------------------------------------------------------------------------
  // Shadows
  // ---------------------------------------------------------------------------
  static List<BoxShadow> shadowSm(Color surface) => [
    BoxShadow(
      color: surface.withValues(alpha: 0.08),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowMd(Color surface) => [
    BoxShadow(
      color: surface.withValues(alpha: 0.1),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowLg(Color surface) => [
    BoxShadow(
      color: surface.withValues(alpha: 0.12),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}
