import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../config/app_environment.dart';
import '../di/dependency_registration.dart';
import '../errors/app_error_handler.dart';
import '../logging/app_logger.dart';
import '../paysa_app.dart';
import '../providers/app_providers.dart';

Future<void> bootstrapApplication({
  AppEnvironment environment = AppEnvironment.development,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.forEnvironment(environment);
  final logger = AppLogger(environment: environment);
  final errorHandler = AppErrorHandler(logger: logger);

  errorHandler.registerGlobalHandlers();

  final dependencies = await registerAppDependencies(
    config: config,
    logger: logger,
  );

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(dependencies.config),
        appLoggerProvider.overrideWithValue(dependencies.logger),
        isarProvider.overrideWithValue(dependencies.isar),
        crashReporterProvider.overrideWithValue(dependencies.crashReporter),
      ],
      child: const PaysaApp(),
    ),
  );
}
