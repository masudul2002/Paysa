import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paysa/app/config/app_config.dart';
import 'package:paysa/app/config/app_environment.dart';
import 'package:paysa/app/errors/crash_reporter.dart';
import 'package:paysa/app/logging/app_logger.dart';
import 'package:paysa/app/paysa_app.dart';
import 'package:paysa/app/providers/app_providers.dart';
import 'package:paysa/features/analytics/domain/entities/analytics_entities.dart';
import 'package:paysa/features/analytics/data/services/analytics_engine_impl.dart';
import 'package:paysa/features/analytics/presentation/providers/analytics_providers.dart';

void main() {
  testWidgets('Paysa app starts on the splash route', (tester) async {
    final engine = AnalyticsEngineImpl(
      getAccounts: () async => [],
      getTransactions: ({from, to}) async => [],
      getLedgers: () async => [],
      getPeople: () async => [],
      getPaymentRequests: ({statusFilter}) async => [],
      getReceipts: () async => [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsEngineProvider.overrideWithValue(engine),
          appConfigProvider.overrideWithValue(
            AppConfig.forEnvironment(AppEnvironment.development),
          ),
          appLoggerProvider.overrideWithValue(
            AppLogger(environment: AppEnvironment.development),
          ),
          crashReporterProvider.overrideWithValue(_TestCrashReporter()),
        ],
        child: const PaysaApp(),
      ),
    );

    // allow initial frame (splash should appear immediately)
    await tester.pump();

    expect(find.text('Paysa'), findsOneWidget);
    expect(find.text('Offline First Personal Finance'), findsOneWidget);

    // wait for splash animation (500ms) + navigation
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

final class _TestCrashReporter implements CrashReporter {
  @override
  void recordError(Object error, StackTrace stackTrace) {}

  @override
  void recordFlutterError(FlutterErrorDetails details) {}
}
