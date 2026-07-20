import 'package:flutter/foundation.dart';

import '../logging/app_logger.dart';

abstract interface class CrashReporter {
  void recordFlutterError(FlutterErrorDetails details);

  void recordError(Object error, StackTrace stackTrace);
}

final class NoopCrashReporter implements CrashReporter {
  const NoopCrashReporter({required this.logger});

  final AppLogger logger;

  @override
  void recordFlutterError(FlutterErrorDetails details) {
    logger.debug('Crash reporter placeholder received a Flutter error.');
  }

  @override
  void recordError(Object error, StackTrace stackTrace) {
    logger.debug('Crash reporter placeholder received an uncaught error.');
  }
}
