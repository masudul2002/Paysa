import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final class AppLocalizationConfig {
  const AppLocalizationConfig._();

  static const supportedLocales = [Locale('en'), Locale('bn')];

  static const delegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];
}
