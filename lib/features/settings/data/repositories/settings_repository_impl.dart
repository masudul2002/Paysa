import 'dart:async';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

/// In-memory settings repository.
///
/// In production, this would persist to Isar or SharedPreferences.
/// The interface is ready for any backend.
final class SettingsRepositoryImpl implements SettingsRepository {
  AppSettings _settings = const AppSettings();
  final _controller = StreamController<AppSettings>.broadcast();

  @override
  Future<AppSettings> load() async => _settings;

  @override
  Future<void> save(AppSettings settings) async {
    _settings = settings.copyWith(version: _settings.version + 1);
    _controller.add(_settings);
  }

  @override
  Stream<AppSettings> watch() => _controller.stream;
}
