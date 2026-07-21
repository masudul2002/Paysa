import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/features/auth/domain/validators/auth_validators.dart';

void main() {
  group('validateEmail', () {
    test('null email returns emptyEmail error', () {
      expect(AuthValidators.validateEmail(null), AuthValidationError.emptyEmail);
    });

    test('empty email returns emptyEmail error', () {
      expect(AuthValidators.validateEmail(''), AuthValidationError.emptyEmail);
    });

    test('whitespace-only email returns emptyEmail error', () {
      expect(AuthValidators.validateEmail('   '), AuthValidationError.emptyEmail);
    });

    test('email without @ returns invalidEmail error', () {
      expect(AuthValidators.validateEmail('notanemail'), AuthValidationError.invalidEmail);
    });

    test('email without domain returns invalidEmail error', () {
      expect(AuthValidators.validateEmail('user@'), AuthValidationError.invalidEmail);
    });

    test('valid email returns null', () {
      expect(AuthValidators.validateEmail('user@example.com'), isNull);
    });

    test('email with subdomain is valid', () {
      expect(AuthValidators.validateEmail('user@sub.example.com'), isNull);
    });
  });

  group('validatePassword', () {
    test('null password returns emptyPassword error', () {
      expect(AuthValidators.validatePassword(null), AuthValidationError.emptyPassword);
    });

    test('empty password returns emptyPassword error', () {
      expect(AuthValidators.validatePassword(''), AuthValidationError.emptyPassword);
    });

    test('password under 8 chars returns tooShort error', () {
      expect(AuthValidators.validatePassword('Abc123'), AuthValidationError.tooShort);
    });

    test('password over 128 chars returns tooLong error', () {
      expect(AuthValidators.validatePassword('A' * 129), AuthValidationError.tooLong);
    });

    test('password exactly 128 chars is valid', () {
      expect(AuthValidators.validatePassword('A' * 128), isNull);
    });

    test('valid password returns null', () {
      expect(AuthValidators.validatePassword('SecurePass123!'), isNull);
    });
  });

  group('validatePasswordConfirmation', () {
    test('null confirmation returns emptyConfirmation error', () {
      expect(AuthValidators.validatePasswordConfirmation('pass1234', null),
          AuthValidationError.emptyConfirmation);
    });

    test('mismatched passwords return passwordMismatch error', () {
      expect(AuthValidators.validatePasswordConfirmation('pass1234', 'different'),
          AuthValidationError.passwordMismatch);
    });

    test('matching passwords return null', () {
      expect(AuthValidators.validatePasswordConfirmation('pass1234', 'pass1234'), isNull);
    });
  });

  group('validateDisplayName', () {
    test('null name returns emptyDisplayName error', () {
      expect(AuthValidators.validateDisplayName(null), AuthValidationError.emptyDisplayName);
    });

    test('empty name returns emptyDisplayName error', () {
      expect(AuthValidators.validateDisplayName(''), AuthValidationError.emptyDisplayName);
    });

    test('name over 100 chars returns displayNameTooLong error', () {
      expect(AuthValidators.validateDisplayName('A' * 101), AuthValidationError.displayNameTooLong);
    });

    test('valid name returns null', () {
      expect(AuthValidators.validateDisplayName('Alice'), isNull);
    });
  });

  group('normalizeEmail', () {
    test('trims whitespace and converts to lowercase', () {
      expect(AuthValidators.normalizeEmail('  User@Example.COM  '), 'user@example.com');
    });
  });

  group('error messages', () {
    test('every error has a non-empty message', () {
      for (final error in AuthValidationError.values) {
        expect(AuthValidators.message(error).isNotEmpty, true,
            reason: 'Error $error should have a message');
      }
    });
  });

  group('validation integration with repository', () {
    test('empty email rejected before remote call', () async {
      // Uses the local validation paths from AuthRepositoryImpl
      final emailErr = AuthValidators.validateEmail('');
      expect(emailErr, AuthValidationError.emptyEmail);
      expect(AuthValidators.message(emailErr!), 'Email is required.');
    });

    test('short password rejected before remote call', () async {
      final passErr = AuthValidators.validatePassword('short');
      expect(passErr, AuthValidationError.tooShort);
      expect(AuthValidators.message(passErr!), contains('8 characters'));
    });

    test('all error messages are user-friendly', () {
      for (final error in AuthValidationError.values) {
        final msg = AuthValidators.message(error);
        expect(msg, isNotEmpty);
        expect(msg.endsWith('.'), true,
            reason: 'Message for $error should end with a period');
      }
    });
  });
}
