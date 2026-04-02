/// TODO: Implement similar error type hierarchies for other features
/// (photo_preview, frames_manager, etc.) to maintain consistent, type-safe
/// error handling across the app instead of using generic string-based errors.
sealed class CameraError implements Exception {
  final String message;
  const CameraError(this.message);

  @override
  String toString() => message;
}

class PermissionError extends CameraError {
  const PermissionError(super.message);
}

class InitializationError extends CameraError {
  const InitializationError(super.message);
}

class NoCameraAvailableError extends CameraError {
  const NoCameraAvailableError(super.message);
}

class SwitchCameraError extends CameraError {
  const SwitchCameraError(super.message);
}

class CaptureError extends CameraError {
  const CaptureError(super.message);
}

class ReinitializationError extends CameraError {
  const ReinitializationError(super.message);
}
