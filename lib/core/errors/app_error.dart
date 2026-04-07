abstract class AppError implements Exception {
  final String message;
  final String userMessage;
  final Object? cause;

  const AppError(this.message, {required this.userMessage, this.cause});

  @override
  String toString() => message;
}

class PermissionError extends AppError {
  const PermissionError(
    super.message, {
    required super.userMessage,
    super.cause,
  });
}

class DatabaseError extends AppError {
  const DatabaseError(
    super.message, {
    required super.userMessage,
    super.cause,
  });
}

class UnexpectedError extends AppError {
  const UnexpectedError(
    super.message, {
    super.userMessage = 'Something went wrong. Please try again.',
    super.cause,
  });
}
