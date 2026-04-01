import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];

  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _currentZoom = 1.0;

  CameraController? get controller => _controller;

  double get minZoom => _minZoom;
  double get maxZoom => _maxZoom;
  double get currentZoom => _currentZoom;

  Future<void> initialize({
    CameraLensDirection direction = CameraLensDirection.back,
  }) async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }

    if (_cameras.isEmpty) {
      throw Exception('No cameras available');
    }

    final camera = _findCamera(direction);
    await _initializeController(camera);
    await _adjustZoomLevels();
  }

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

  Future<void> disposeController() async {
    await _controller?.dispose();
    _controller = null;
  }

  Future<void> setZoomLevel(double zoom) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final clampedZoom = zoom.clamp(_minZoom, _maxZoom);
      await _controller!.setZoomLevel(clampedZoom);
      _currentZoom = clampedZoom;
    } catch (e) {
      debugPrint('Error setting zoom level: $e');
    }
  }

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
      _currentZoom = _minZoom;
      await _controller!.setZoomLevel(_minZoom);
    } catch (e) {
      debugPrint('Error getting zoom levels: $e');
      _minZoom = 1.0;
      _maxZoom = 1.0;
      _currentZoom = 1.0;
    }
  }

  CameraDescription _findCamera(CameraLensDirection direction) {
    return _cameras.firstWhere(
      (c) => c.lensDirection == direction,
      orElse: () => _cameras.first,
    );
  }
}
