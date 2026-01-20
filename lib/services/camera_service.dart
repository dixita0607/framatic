import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Service for managing camera initialization and controls
class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;

  // Zoom state
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _currentZoom = 1.0;

  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;
  List<CameraDescription>? get cameras => _cameras;
  int get selectedCameraIndex => _selectedCameraIndex;

  // Zoom getters
  double get minZoom => _minZoom;
  double get maxZoom => _maxZoom;
  double get currentZoom => _currentZoom;

  /// Check if device supports ultra-wide (0.5x) zoom
  bool get supportsUltraWide => _minZoom < 1.0;

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
      // Initialize zoom levels after controller is ready
      await _initializeZoomLevels();
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

  /// Query and store device zoom capabilities
  Future<void> _initializeZoomLevels() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      _minZoom = await _controller!.getMinZoomLevel();
      _maxZoom = await _controller!.getMaxZoomLevel();
      // Start at minimum zoom to give widest field of view
      _currentZoom = _minZoom;
      await _controller!.setZoomLevel(_minZoom);
      debugPrint('Zoom range: $_minZoom - $_maxZoom (ultra-wide: $supportsUltraWide)');
    } catch (e) {
      debugPrint('Error getting zoom levels: $e');
      _minZoom = 1.0;
      _maxZoom = 1.0;
      _currentZoom = 1.0;
    }
  }

  /// Set zoom level (actual zoom value, e.g., 0.5, 1.0, 2.0)
  Future<void> setZoomLevel(double zoom) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      final clampedZoom = zoom.clamp(_minZoom, _maxZoom);
      await _controller!.setZoomLevel(clampedZoom);
      _currentZoom = clampedZoom;
    } catch (e) {
      debugPrint('Error setting zoom level: $e');
    }
  }

  /// Get formatted zoom level string (e.g., "0.5x", "1.0x", "2.0x")
  String get zoomLevelString {
    return '${_currentZoom.toStringAsFixed(1)}x';
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
