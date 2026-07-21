import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl();
});

final settingsProvider = StreamProvider<AppSettings>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.watch();
});

final settingsThemeModeProvider = Provider<ThemeModePreference>((ref) {
  final settings = ref.watch(settingsProvider).asData?.value;
  return settings?.themeMode ?? ThemeModePreference.system;
});

final settingsCurrencyProvider = Provider<CurrencyConfig>((ref) {
  final settings = ref.watch(settingsProvider).asData?.value;
  return settings?.currency ?? const CurrencyConfig();
});

final settingsNotificationsProvider = Provider<NotificationPreferences>((ref) {
  final settings = ref.watch(settingsProvider).asData?.value;
  return settings?.notifications ?? const NotificationPreferences();
});

final settingsAccessibilityProvider = Provider<AccessibilityPreferences>((ref) {
  final settings = ref.watch(settingsProvider).asData?.value;
  return settings?.accessibility ?? const AccessibilityPreferences();
});
