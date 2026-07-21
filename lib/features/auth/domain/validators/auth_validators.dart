/// Email and password validation rules.
///
/// All business logic for auth validation lives here,
/// independent of any UI or data layer.

final class AuthValidators {
  const AuthValidators._();

  /// Validates email format. Returns [AuthValidationError] or null.
  static AuthValidationError? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return AuthValidationError.emptyEmail;
    }

    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(email.trim())) {
      return AuthValidationError.invalidEmail;
    }

    return null;
  }

  /// Validates password strength. Returns [AuthValidationError] or null.
  static AuthValidationError? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return AuthValidationError.emptyPassword;
    }

    if (password.length < 8) {
      return AuthValidationError.tooShort;
    }

    if (password.length > 128) {
      return AuthValidationError.tooLong;
    }

    return null;
  }

  /// Validates password confirmation matches.
  static AuthValidationError? validatePasswordConfirmation(
    String? password,
    String? confirmation,
  ) {
    if (confirmation == null || confirmation.isEmpty) {
      return AuthValidationError.emptyConfirmation;
    }

    if (password != confirmation) {
      return AuthValidationError.passwordMismatch;
    }

    return null;
  }

  /// Validates display name for registration.
  static AuthValidationError? validateDisplayName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return AuthValidationError.emptyDisplayName;
    }

    if (name.trim().length > 100) {
      return AuthValidationError.displayNameTooLong;
    }

    return null;
  }

  /// Normalizes email: trims whitespace, converts to lowercase.
  static String normalizeEmail(String email) => email.trim().toLowerCase();

  /// Returns a human-readable error message for an [AuthValidationError].
  static String message(AuthValidationError error) => switch (error) {
    AuthValidationError.emptyEmail => 'Email is required.',
    AuthValidationError.invalidEmail => 'Please enter a valid email address.',
    AuthValidationError.emptyPassword => 'Password is required.',
    AuthValidationError.tooShort => 'Password must be at least 8 characters.',
    AuthValidationError.tooLong => 'Password must be under 128 characters.',
    AuthValidationError.emptyConfirmation => 'Please confirm your password.',
    AuthValidationError.passwordMismatch => 'Passwords do not match.',
    AuthValidationError.emptyDisplayName => 'Display name is required.',
    AuthValidationError.displayNameTooLong => 'Display name must be under 100 characters.',
    AuthValidationError.duplicateEmail => 'An account with this email already exists.',
    AuthValidationError.userNotFound => 'No account found with this email.',
    AuthValidationError.wrongPassword => 'Incorrect password. Please try again.',
    AuthValidationError.unknown => 'An error occurred. Please try again.',
  };
}

/// Possible authentication validation errors.
enum AuthValidationError {
  emptyEmail,
  invalidEmail,
  emptyPassword,
  tooShort,
  tooLong,
  emptyConfirmation,
  passwordMismatch,
  emptyDisplayName,
  displayNameTooLong,
  duplicateEmail,
  userNotFound,
  wrongPassword,
  unknown;
}
