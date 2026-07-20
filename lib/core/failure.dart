/// Lightweight failure representation for user-facing errors.
final class Failure {
  const Failure({required this.message, this.code, this.details});

  final String message;
  final String? code;
  final Object? details;

  @override
  String toString() => 'Failure(code: $code, message: $message)';
}
