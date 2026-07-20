import 'package:logger/logger.dart';

import '../config/app_environment.dart';

final class AppLogger {
  AppLogger({required AppEnvironment environment})
    : _logger = Logger(
        level: environment == AppEnvironment.production
            ? Level.info
            : Level.debug,
        printer: PrettyPrinter(methodCount: 0),
      );

  final Logger _logger;

  void debug(String message) => _logger.d(message);

  void info(String message) => _logger.i(message);

  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
