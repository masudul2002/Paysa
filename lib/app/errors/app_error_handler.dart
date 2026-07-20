import 'package:flutter/foundation.dart';

import '../logging/app_logger.dart';
import 'crash_reporter.dart';

final class AppErrorHandler {
  AppErrorHandler({required this.logger, this.crashReporter});

  final AppLogger logger;
  final CrashReporter? crashReporter;

  void registerGlobalHandlers() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      logger.error(
        'Flutter framework error.',
        error: details.exception,
        stackTrace: details.stack,
      );
      crashReporter?.recordFlutterError(details);
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      logger.error(
        'Uncaught platform error.',
        error: error,
        stackTrace: stackTrace,
      );
      crashReporter?.recordError(error, stackTrace);
      return true;
    };
  }
}
