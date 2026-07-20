import 'failure.dart';

/// Simple Result wrapper to represent success or failure without adding a heavy dependency.
sealed class Result<T> {
  const Result._();
}

final class Success<T> extends Result<T> {
  const Success(this.value) : super._();
  final T value;
}

final class ErrorResult<T> extends Result<T> {
  const ErrorResult(this.failure) : super._();
  final Failure failure;
}
