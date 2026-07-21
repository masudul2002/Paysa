import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/app/theme/app_colors.dart';
import 'package:paysa/app/theme/app_theme.dart';
import 'package:paysa/app/theme/design_tokens.dart';

void main() {
  group('DesignTokens', () {
    test('spacing values are non-negative', () {
      expect(DesignTokens.space0, 0);
      expect(DesignTokens.space8, 8);
      expect(DesignTokens.space16, 16);
      expect(DesignTokens.space24, 24);
      expect(DesignTokens.space48, 48);
    });

    test('radius values are non-negative', () {
      expect(DesignTokens.radiusSm, 8);
      expect(DesignTokens.radiusMd, 12);
      expect(DesignTokens.radiusLg, 16);
      expect(DesignTokens.radiusFull, 999);
    });

    test('semantic colors are defined', () {
      expect(DesignTokens.brand, const Color(0xFF0F766E));
      expect(DesignTokens.success, const Color(0xFF16A34A));
      expect(DesignTokens.warning, const Color(0xFFF59E0B));
      expect(DesignTokens.error, const Color(0xFFDC2626));
    });

    test('finance colors are defined', () {
      expect(DesignTokens.income, const Color(0xFF16A34A));
      expect(DesignTokens.expense, const Color(0xFFDC2626));
      expect(DesignTokens.pending, const Color(0xFFD97706));
    });

    test('elevation values are non-negative', () {
      expect(DesignTokens.elevationNone, 0);
      expect(DesignTokens.elevationCard, 2);
    });

    test('touch targets meet accessibility', () {
      expect(DesignTokens.minTouchSize, greaterThanOrEqualTo(48));
    });
  });

  group('PaysaColors extension', () {
    test('constructor sets values', () {
      const colors = PaysaColors(
        income: Colors.green,
        expense: Colors.red,
        pending: Colors.orange,
        receivable: Colors.green,
        payable: Colors.red,
      );
      expect(colors.income, Colors.green);
      expect(colors.expense, Colors.red);
    });

    test('copyWith preserves unchanged fields', () {
      const colors = PaysaColors(
        income: Colors.green, expense: Colors.red,
        pending: Colors.orange, receivable: Colors.green, payable: Colors.red,
      );
      final copy = colors.copyWith(income: Colors.blue);
      expect(copy.income, Colors.blue);
      expect(copy.expense, Colors.red);
    });
  });

  group('AppTheme', () {
    test('light theme has Material 3', () {
      final theme = AppTheme.light();
      expect(theme.useMaterial3, true);
    });

    test('dark theme is different from light', () {
      final light = AppTheme.light();
      final dark = AppTheme.dark();
      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);
    });

    test('theme has PaysaColors extension', () {
      final theme = AppTheme.light();
      final colors = theme.extension<PaysaColors>();
      expect(colors, isNotNull);
      expect(colors!.income, DesignTokens.income);
    });
  });
}
