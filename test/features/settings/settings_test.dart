import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/features/settings/domain/entities/app_settings.dart';
import 'package:paysa/features/settings/data/repositories/settings_repository_impl.dart';

final _default = const AppSettings();

void main() {
  group('AppSettings', () {
    test('default values', () {
      expect(_default.themeMode, ThemeModePreference.system);
      expect(_default.hideBalance, false);
      expect(_default.appLockEnabled, false);
      expect(_default.currency.code, 'USD');
    });

    test('copyWith updates theme', () {
      final updated = _default.copyWith(themeMode: ThemeModePreference.dark);
      expect(updated.themeMode, ThemeModePreference.dark);
      expect(updated.hideBalance, false); // unchanged
    });

    test('copyWith increments version', () async {
      final repo = SettingsRepositoryImpl();
      final loaded = await repo.load();
      await repo.save(loaded.copyWith(hideBalance: true));
      final saved = await repo.load();
      expect(saved.hideBalance, true);
      expect(saved.version, 2);
    });

    test('multiple saves accumulate', () async {
      final repo = SettingsRepositoryImpl();
      final s = await repo.load();
      await repo.save(s.copyWith(hideBalance: true));
      await repo.save(s.copyWith(hideBalance: true, appLockEnabled: true));
      final saved = await repo.load();
      expect(saved.hideBalance, true);
      expect(saved.appLockEnabled, true);
    });
  });

  group('CurrencyConfig', () {
    test('format USD amount', () {
      final c = const CurrencyConfig();
      expect(c.format(100000), r'$1,000.00');
      expect(c.format(500), r'$5.00');
    });

    test('BDT format', () {
      final c = const CurrencyConfig(code: 'BDT', symbol: '৳');
      expect(c.format(150000), '৳1,500.00');
    });
  });

  group('NotificationPreferences', () {
    test('default all true except daily summary', () {
      final n = const NotificationPreferences();
      expect(n.paymentReminders, true);
      expect(n.dailySummary, false);
    });

    test('copyWith', () {
      final n = const NotificationPreferences();
      final c = n.copyWith(paymentReminders: false);
      expect(c.paymentReminders, false);
      expect(c.ledgerReminders, true); // unchanged
    });
  });

  group('AccessibilityPreferences', () {
    test('default all false', () {
      final a = const AccessibilityPreferences();
      expect(a.largeText, false);
      expect(a.reducedMotion, false);
      expect(a.highContrast, false);
    });
  });

  group('SettingsRepository', () {
    test('load returns defaults initially', () async {
      final repo = SettingsRepositoryImpl();
      final settings = await repo.load();
      expect(settings.themeMode, ThemeModePreference.system);
    });

    test('watch emits after save', () async {
      final repo = SettingsRepositoryImpl();
      final emitted = <AppSettings>[];
      final sub = repo.watch().listen(emitted.add);
      await repo.save(const AppSettings().copyWith(hideBalance: true));
      await Future(() {}); // Wait for stream
      expect(emitted.length, 1);
      sub.cancel();
    });
  });

  group('Enums', () {
    test('ThemeModePreference has 3 values', () {
      expect(ThemeModePreference.values.length, 3);
    });
    test('DateFormatStyle has 3 values', () {
      expect(DateFormatStyle.values.length, 3);
    });
    test('FirstDayOfWeek has 3 values', () {
      expect(FirstDayOfWeek.values.length, 3);
    });
    test('DefaultReportRange has 4 values', () {
      expect(DefaultReportRange.values.length, 4);
    });
    test('AutoLockTimeout has 4 values', () {
      expect(AutoLockTimeout.values.length, 4);
    });
  });
}
