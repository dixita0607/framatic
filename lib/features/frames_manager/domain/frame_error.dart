import 'package:framatic/core/errors/app_error.dart';

sealed class FrameError extends AppError {
  const FrameError(super.message, {required super.userMessage, super.cause});
}

class FindFrameError extends FrameError {
  const FindFrameError(super.message, {required super.userMessage, super.cause});
}

class CreateFrameError extends FrameError {
  const CreateFrameError(
    super.message, {
    required super.userMessage,
    super.cause,
  });
}

class UpdateFrameError extends FrameError {
  const UpdateFrameError(
    super.message, {
    required super.userMessage,
    super.cause,
  });
}

class DeleteFrameError extends FrameError {
  const DeleteFrameError(
    super.message, {
    required super.userMessage,
    super.cause,
  });
}

class ReorderFrameError extends FrameError {
  const ReorderFrameError(
    super.message, {
    required super.userMessage,
    super.cause,
  });
}
