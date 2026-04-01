import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:framatic/core/services/permission_service.dart';
import 'package:framatic/features/camera/data/camera_service.dart';

class CameraProvider extends ChangeNotifier with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();

  CameraProvider() {
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  bool _isLoading = true;
  bool _isCapturing = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isCapturing => _isCapturing;
  String? get errorMessage => _errorMessage;
  CameraController? get controller => _cameraService.controller;
  double get minZoom => _cameraService.minZoom;
  double get maxZoom => _cameraService.maxZoom;
  double get currentZoom => _cameraService.currentZoom;

  Future<void> retry() => _initialize();

  Future<void> _initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final hasPermission = await PermissionService.isCameraPermissionGranted;
      if (!hasPermission) {
        final granted = await PermissionService.requestCameraPermission();
        if (!granted) {
          _errorMessage = 'Camera permission is required';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      await _cameraService.initialize();
    } catch (e) {
      _errorMessage = 'Failed to initialize camera: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setZoomLevel(double zoom) async {
    await _cameraService.setZoomLevel(zoom);
    notifyListeners();
  }

  Future<void> switchCamera() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _cameraService.toggleCameraDirection();
    } catch (e) {
      _errorMessage = 'Failed to switch camera: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<XFile?> takePicture() async {
    if (_isCapturing) return null;

    _isCapturing = true;
    notifyListeners();

    try {
      return await _cameraService.takePicture();
    } finally {
      _isCapturing = false;
      notifyListeners();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraService.controller == null ||
        !_cameraService.controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraService.disposeController();
      notifyListeners();
    } else if (state == AppLifecycleState.resumed) {
      _initialize();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraService.disposeController();
    super.dispose();
  }
}
