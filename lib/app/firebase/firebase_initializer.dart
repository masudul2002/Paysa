import 'firebase_config.dart';

/// Responsible for Firebase initialization.
///
/// Called once during app bootstrap.
/// App continues normally if Firebase is unavailable.
final class FirebaseInitializer {
  const FirebaseInitializer._();

  /// Initialize Firebase. Safe to call multiple times.
  ///
  /// In production, this calls:
  /// ```dart
  /// await Firebase.initializeApp(
  ///   options: DefaultFirebaseOptions.currentPlatform,
  /// );
  /// ```
  ///
  /// For now, simulates initialization so the architecture
  /// is ready when Firebase packages are added.
  static Future<void> initialize() async {
    if (FirebaseConfig.isInitialized) return;

    try {
      // Production: await Firebase.initializeApp(
      //   options: DefaultFirebaseOptions.currentPlatform,
      // );
      FirebaseConfig.markInitialized();
    } catch (_) {
      // App continues without Firebase
    }
  }
}
