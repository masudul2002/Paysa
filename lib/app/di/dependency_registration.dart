import '../config/app_config.dart';
import '../database/paysa_database.dart';
import '../errors/crash_reporter.dart';
import '../logging/app_logger.dart';
import 'app_dependency_container.dart';

Future<AppDependencyContainer> registerAppDependencies({
  required AppConfig config,
  required AppLogger logger,
}) async {
  final crashReporter = NoopCrashReporter(logger: logger);
  final isar = await PaysaDatabase.open();

  logger.info('Application dependencies registered.');

  return AppDependencyContainer(
    config: config,
    logger: logger,
    isar: isar,
    crashReporter: crashReporter,
  );
}
