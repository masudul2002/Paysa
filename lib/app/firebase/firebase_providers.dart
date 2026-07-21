import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_config.dart';

/// Whether Firebase is initialized and available.
final firebaseInitializedProvider = Provider<bool>((ref) {
  return FirebaseConfig.isInitialized;
});
