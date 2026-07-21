import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/app/firebase/firebase_config.dart';
import 'package:paysa/app/firebase/firebase_initializer.dart';

void main() {
  setUp(() {
    FirebaseConfig.reset();
  });

  group('FirebaseInitializer', () {
    test('initialize marks as initialized', () async {
      expect(FirebaseConfig.isInitialized, false);
      await FirebaseInitializer.initialize();
      expect(FirebaseConfig.isInitialized, true);
    });

    test('initialize is idempotent', () async {
      await FirebaseInitializer.initialize();
      await FirebaseInitializer.initialize();
      expect(FirebaseConfig.isInitialized, true);
    });
  });

  group('FirebaseConfig', () {
    test('isAvailable returns true', () {
      expect(FirebaseConfig.isAvailable, true);
    });

    test('reset clears initialized state', () {
      FirebaseConfig.markInitialized();
      expect(FirebaseConfig.isInitialized, true);
      FirebaseConfig.reset();
      expect(FirebaseConfig.isInitialized, false);
    });
  });
}
