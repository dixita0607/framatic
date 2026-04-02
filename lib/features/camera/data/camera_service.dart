import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:framatic/features/camera/data/camera_repository.dart';
import 'package:framatic/features/camera/domain/camera_error.dart';

class CameraService implements CameraRepository {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];

  double _minZoom = 1.0;
  double _maxZoom = 1.0;

  @override
  CameraController? get controller => _controller;

  @override
  Future<void> initialize({
    CameraLensDirection direction = CameraLensDirection.back,
  }) async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }

    if (_cameras.isEmpty) {
      throw NoCameraAvailableError('No cameras available on this device');
    }

    final camera = _findCamera(direction);
    await _initializeController(camera);
    await _adjustZoomLevels();
  }

  @override
  Future<(double minZoom, double maxZoom)> getZoomLimits() async {
    return (_minZoom, _maxZoom);
  }

  /// Re-initialize the controller after it's been disposed (e.g., from app lifecycle).
  /// Useful when the app resumes after being paused.
  @override
  Future<void> reinitialize() async {
    if (_cameras.isEmpty) {
      throw StateError('Cameras not yet discovered. Call create() first.');
    }
    final currentDirection = _controller?.description.lensDirection ?? CameraLensDirection.back;
    final camera = _findCamera(currentDirection);
    await _initializeController(camera);
    await _adjustZoomLevels();
  }

  @override
  Future<void> toggleCameraDirection() async {
    if (_cameras.length < 2 || _controller == null) return;

    final currentDirection = _controller!.description.lensDirection;
    final targetDirection = currentDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;

    final camera = _findCamera(targetDirection);
    await _controller!.setDescription(camera);
    await _adjustZoomLevels();
  }

  @override
  Future<void> disposeController() async {
    await _controller?.dispose();
    _controller = null;
  }

  @override
  Future<void> setZoomLevel(double zoom) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final clampedZoom = zoom.clamp(_minZoom, _maxZoom);
      await _controller!.setZoomLevel(clampedZoom);
    } catch (e) {
      debugPrint('Error setting zoom level: $e');
    }
  }

  @override
  Future<XFile?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return null;
    if (_controller!.value.isTakingPicture) return null;

    try {
      return await _controller!.takePicture();
    } catch (e) {
      debugPrint('Error taking picture: $e');
      return null;
    }
  }

  Future<void> _initializeController(CameraDescription camera) async {
    await disposeController();

    _controller = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
    } catch (e) {
      debugPrint('Error initializing camera controller: $e');
      rethrow;
    }
  }

  Future<void> _adjustZoomLevels() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      _minZoom = await _controller!.getMinZoomLevel();
      _maxZoom = await _controller!.getMaxZoomLevel();
      await _controller!.setZoomLevel(_minZoom);
    } catch (e) {
      debugPrint('Error getting zoom levels: $e');
      _minZoom = 1.0;
      _maxZoom = 1.0;
    }
  }

  CameraDescription _findCamera(CameraLensDirection direction) {
    return _cameras.firstWhere(
      (c) => c.lensDirection == direction,
      orElse: () => _cameras.first,
    );
  }
}
