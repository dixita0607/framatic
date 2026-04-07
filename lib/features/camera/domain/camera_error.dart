import 'package:framatic/core/errors/app_error.dart';

sealed class CameraError extends AppError {
  const CameraError(super.message, {required super.userMessage, super.cause});
}

class NoCameraAvailableError extends CameraError {
  const NoCameraAvailableError(
    super.message, {
    required super.userMessage,
    super.cause,
  });
}

class InitializeCameraError extends CameraError {
  const InitializeCameraError(
    super.message, {
    required super.userMessage,
    super.cause,
  });
}

class SwitchCameraError extends CameraError {
  const SwitchCameraError(
    super.message, {
    required super.userMessage,
    super.cause,
  });
}

class CaptureCameraError extends CameraError {
  const CaptureCameraError(
    super.message, {
    required super.userMessage,
    super.cause,
  });
}

class ReinitializeCameraError extends CameraError {
  const ReinitializeCameraError(
    super.message, {
    required super.userMessage,
    super.cause,
  });
}
