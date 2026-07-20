import 'package:isar/isar.dart';

import '../config/app_config.dart';
import '../errors/crash_reporter.dart';
import '../logging/app_logger.dart';

final class AppDependencyContainer {
  const AppDependencyContainer({
    required this.config,
    required this.logger,
    required this.isar,
    required this.crashReporter,
  });

  final AppConfig config;
  final AppLogger logger;
  final Isar isar;
  final CrashReporter crashReporter;
}
