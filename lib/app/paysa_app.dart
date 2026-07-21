import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/domain/entities/app_settings.dart';
import '../features/settings/presentation/providers/settings_providers.dart';
import 'localization/app_localization_config.dart';
import 'providers/app_providers.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

final class PaysaApp extends ConsumerWidget {
  const PaysaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(settingsThemeModeProvider);

    final effectiveMode = switch (themeMode) {
      ThemeModePreference.system => ThemeMode.system,
      ThemeModePreference.light => ThemeMode.light,
      ThemeModePreference.dark => ThemeMode.dark,
    };

    return MaterialApp.router(
      title: config.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(null),
      darkTheme: AppTheme.dark(null),
      themeMode: effectiveMode,
      routerConfig: router,
      localizationsDelegates: AppLocalizationConfig.delegates,
      supportedLocales: AppLocalizationConfig.supportedLocales,
      locale: const Locale('en'),
    );
  }
}
