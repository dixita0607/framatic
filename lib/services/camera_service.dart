import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Service for managing camera initialization and controls
class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;

  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;
  List<CameraDescription>? get cameras => _cameras;
  int get selectedCameraIndex => _selectedCameraIndex;

  /// Initialize available cameras
  Future<void> initializeCameras() async {
    try {
      _cameras = await availableCameras();
    } catch (e) {
      debugPrint('Error initializing cameras: $e');
      rethrow;
    }
  }

  /// Initialize camera controller with the selected camera
  Future<void> initializeController({int cameraIndex = 0}) async {
    if (_cameras == null || _cameras!.isEmpty) {
      await initializeCameras();
    }

    if (_cameras == null || _cameras!.isEmpty) {
      throw Exception('No cameras available');
    }

    _selectedCameraIndex = cameraIndex;

    // Dispose previous controller if exists
    await _controller?.dispose();

    _controller = CameraController(
      _cameras![_selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
    } catch (e) {
      debugPrint('Error initializing camera controller: $e');
      rethrow;
    }
  }

  /// Switch between front and back cameras
  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      return;
    }

    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    await initializeController(cameraIndex: _selectedCameraIndex);
  }

  /// Set zoom level (0.0 to 1.0)
  Future<void> setZoomLevel(double zoom) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      final maxZoom = await _controller!.getMaxZoomLevel();
      final minZoom = await _controller!.getMinZoomLevel();
      final zoomLevel = minZoom + (zoom * (maxZoom - minZoom));
      await _controller!.setZoomLevel(zoomLevel.clamp(minZoom, maxZoom));
      _currentZoom = zoom;
    } catch (e) {
      debugPrint('Error setting zoom level: $e');
    }
  }

  // Store current zoom level
  double _currentZoom = 0.0;

  /// Get current zoom level (normalized 0.0 to 1.0)
  double getZoomLevel() {
    return _currentZoom;
  }

  /// Set flash mode
  Future<void> setFlashMode(FlashMode mode) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      await _controller!.setFlashMode(mode);
    } catch (e) {
      debugPrint('Error setting flash mode: $e');
    }
  }

  /// Take a picture
  Future<XFile?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }

    if (_controller!.value.isTakingPicture) {
      return null;
    }

    try {
      return await _controller!.takePicture();
    } catch (e) {
      debugPrint('Error taking picture: $e');
      return null;
    }
  }

  /// Dispose camera controller
  void dispose() {
    _controller?.dispose();
    _controller = null;
  }
}
