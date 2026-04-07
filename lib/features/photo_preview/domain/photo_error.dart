import 'package:framatic/core/errors/app_error.dart';

sealed class PhotoError extends AppError {
  const PhotoError(super.message, {required super.userMessage, super.cause});
}

class ProcessPhotoError extends PhotoError {
  const ProcessPhotoError(
    super.message, {
    required super.userMessage,
    super.cause,
  });
}

class DecodePhotoError extends PhotoError {
  const DecodePhotoError(
    super.message, {
    required super.userMessage,
    super.cause,
  });
}

class SavePhotoError extends PhotoError {
  const SavePhotoError(
    super.message, {
    required super.userMessage,
    super.cause,
  });
}
