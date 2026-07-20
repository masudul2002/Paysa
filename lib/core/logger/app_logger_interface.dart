import '../failure.dart';

/// Minimal logger abstraction used by core. Existing AppLogger under app/logging
/// can be adapted to implement this interface where needed.
abstract interface class CoreLogger {
  void debug(String message);
  void info(String message);
  void warn(String message, {Object? error, StackTrace? stackTrace});
  void error(String message, {Object? error, StackTrace? stackTrace});

  /// Placeholder to record a Failure (e.g., before sending to remote reporting).
  void recordFailure(Failure failure);
}
