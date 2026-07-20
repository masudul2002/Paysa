import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../config/app_config.dart';
import '../errors/crash_reporter.dart';
import '../logging/app_logger.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('AppConfig must be provided during bootstrap.');
});

final appLoggerProvider = Provider<AppLogger>((ref) {
  throw UnimplementedError('AppLogger must be provided during bootstrap.');
});

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('Isar must be provided during bootstrap.');
});

final crashReporterProvider = Provider<CrashReporter>((ref) {
  throw UnimplementedError('CrashReporter must be provided during bootstrap.');
});
