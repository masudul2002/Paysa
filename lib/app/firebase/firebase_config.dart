/// Firebase configuration per environment.
///
/// Each environment can have its own Firebase project.
/// In production, these values come from google-services.json / GoogleService-Info.plist.
final class FirebaseConfig {
  const FirebaseConfig._();

  /// Whether Firebase is available on this platform.
  /// Web and desktop may not have Firebase support.
  static bool get isAvailable {
    // In production, check platform:
    // return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    return true;
  }

  /// Whether Firebase has been initialized.
  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  /// Mark Firebase as initialized.
  static void markInitialized() { _initialized = true; }

  /// Reset for testing.
  static void reset() { _initialized = false; }
}
