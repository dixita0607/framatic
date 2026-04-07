import 'package:camera/camera.dart';

abstract interface class CameraRepository {
  // Minimal state exposure: only the controller for UI rendering
  CameraController? get controller;

  Future<void> initialize({
    CameraLensDirection direction = .back,
  });

  Future<(double minZoom, double maxZoom)> getZoomLimits();
  Future<void> reinitialize();

  Future<void> toggleCameraDirection();
  Future<void> disposeController();
  Future<void> setZoomLevel(double zoom);
  Future<XFile?> takePicture();
}
