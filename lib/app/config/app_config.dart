import 'app_environment.dart';

final class AppConfig {
  const AppConfig({
    required this.name,
    required this.version,
    required this.organization,
    required this.environment,
  });

  factory AppConfig.forEnvironment(AppEnvironment environment) {
    return AppConfig(
      name: 'Paysa',
      version: '0.1.0-dev',
      organization: 'com.paysa.app',
      environment: environment,
    );
  }

  final String name;
  final String version;
  final String organization;
  final AppEnvironment environment;

  bool get isProduction => environment == AppEnvironment.production;
}
