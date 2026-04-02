import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:framatic/core/services/permission_service.dart';
import 'package:framatic/features/camera/data/camera_repository.dart';
import 'package:framatic/features/camera/domain/camera_error.dart';

class CameraProvider extends ChangeNotifier with WidgetsBindingObserver {
  final CameraRepository _cameraRepository;

  CameraProvider(CameraRepository cameraRepository)
      : _cameraRepository = cameraRepository {
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  bool _isLoading = true;
  bool _isCapturing = false;
  CameraError? _error;

  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _currentZoom = 1.0;

  bool get isLoading => _isLoading;
  bool get isCapturing => _isCapturing;
  CameraError? get error => _error;
  CameraController? get controller => _cameraRepository.controller;
  double get minZoom => _minZoom;
  double get maxZoom => _maxZoom;
  double get currentZoom => _currentZoom;

  Future<void> retry() => _initialize();

  Future<void> _initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final hasPermission = await PermissionService.isCameraPermissionGranted;
      if (!hasPermission) {
        final granted = await PermissionService.requestCameraPermission();
        if (!granted) {
          _error = PermissionError('Camera permission is required');
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      await _cameraRepository.initialize();
      final (minZoom, maxZoom) = await _cameraRepository.getZoomLimits();
      _minZoom = minZoom;
      _maxZoom = maxZoom;
      _currentZoom = minZoom;
    } on CameraError catch (e) {
      _error = e;
    } catch (e) {
      _error = InitializationError('Failed to initialize camera: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setZoomLevel(double zoom) async {
    final clampedZoom = zoom.clamp(_minZoom, _maxZoom);
    await _cameraRepository.setZoomLevel(clampedZoom);
    _currentZoom = clampedZoom;
    notifyListeners();
  }

  Future<void> switchCamera() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _cameraRepository.toggleCameraDirection();
      final (minZoom, maxZoom) = await _cameraRepository.getZoomLimits();
      _minZoom = minZoom;
      _maxZoom = maxZoom;
      _currentZoom = minZoom;
    } catch (e) {
      _error = SwitchCameraError('Failed to switch camera: $e');
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
      return await _cameraRepository.takePicture();
    } finally {
      _isCapturing = false;
      notifyListeners();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _cameraRepository.disposeController();
      notifyListeners();
    } else if (state == AppLifecycleState.resumed) {
      // Re-initialize the camera controller after app resumes
      _reinitialize();
    }
  }

  Future<void> _reinitialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _cameraRepository.reinitialize();
      final (minZoom, maxZoom) = await _cameraRepository.getZoomLimits();
      _minZoom = minZoom;
      _maxZoom = maxZoom;
      _currentZoom = minZoom;
    } on CameraError catch (e) {
      _error = e;
    } catch (e) {
      _error = ReinitializationError('Failed to reinitialize camera: $e');
      debugPrint('Error reinitializing camera: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraRepository.disposeController();
    super.dispose();
  }
}
