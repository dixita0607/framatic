import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/features/camera/data/camera_repository.dart';
import 'package:framatic/features/camera/domain/camera_error.dart';
import 'package:framatic/features/camera/presentation/camera_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const permissionChannel = MethodChannel(
    'flutter.baseflow.com/permissions/methods',
  );

  late _FakeCameraRepository repository;

  setUp(() {
    repository = _FakeCameraRepository();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
  });

  void mockCameraPermission({
    required bool isGranted,
    bool requestGranted = true,
  }) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (call) async {
          switch (call.method) {
            case 'checkPermissionStatus':
              expect(call.arguments, 1);
              return isGranted ? 1 : 0;
            case 'requestPermissions':
              expect(call.arguments, [1]);
              return <int, int>{1: requestGranted ? 1 : 0};
            default:
              fail('Unexpected permission method: ${call.method}');
          }
        });
  }

  test(
    'initializes repository and zoom limits when permission is granted',
    () async {
      mockCameraPermission(isGranted: true);
      repository.zoomLimits = (0.5, 4.0);

      final provider = CameraProvider(repository);
      addTearDown(provider.dispose);
      await _waitForInitialization(provider);

      expect(repository.initializeCalls, 1);
      expect(provider.error, isNull);
      expect(provider.minZoom, 0.5);
      expect(provider.maxZoom, 4.0);
      expect(provider.currentZoom, 0.5);
    },
  );

  test(
    'requests camera permission and stops when permission is denied',
    () async {
      mockCameraPermission(isGranted: false, requestGranted: false);

      final provider = CameraProvider(repository);
      addTearDown(provider.dispose);
      await _waitForInitialization(provider);

      expect(repository.initializeCalls, 0);
      expect(provider.error, isA<PermissionError>());
      expect(provider.error?.userMessage, 'Camera permission is required.');
    },
  );

  test('wraps unexpected initialization failures', () async {
    mockCameraPermission(isGranted: true);
    repository.initializeError = StateError('camera unavailable');

    final provider = CameraProvider(repository);
    addTearDown(provider.dispose);
    await _waitForInitialization(provider);

    expect(provider.error, isA<InitializeCameraError>());
    expect(provider.error?.cause, isA<StateError>());
  });

  test('setZoomLevel clamps zoom before sending it to repository', () async {
    mockCameraPermission(isGranted: true);
    repository.zoomLimits = (1.0, 3.0);
    final provider = CameraProvider(repository);
    addTearDown(provider.dispose);
    await _waitForInitialization(provider);

    await provider.setZoomLevel(9.0);

    expect(repository.zoomLevels, [3.0]);
    expect(provider.currentZoom, 3.0);
  });

  test('switchCamera toggles repository and refreshes zoom limits', () async {
    mockCameraPermission(isGranted: true);
    repository.zoomLimits = (1.0, 5.0);
    final provider = CameraProvider(repository);
    addTearDown(provider.dispose);
    await _waitForInitialization(provider);

    repository.zoomLimits = (0.8, 2.5);
    await provider.switchCamera();

    expect(repository.toggleCameraDirectionCalls, 1);
    expect(provider.isLoading, isFalse);
    expect(provider.minZoom, 0.8);
    expect(provider.maxZoom, 2.5);
    expect(provider.currentZoom, 0.8);
  });

  test('takePicture prevents overlapping captures', () async {
    mockCameraPermission(isGranted: true);
    final capture = Completer<XFile>();
    repository.takePictureResult = capture.future;
    final provider = CameraProvider(repository);
    addTearDown(provider.dispose);
    await _waitForInitialization(provider);

    final firstCapture = provider.takePicture();
    await pumpEventQueue();
    final secondCapture = await provider.takePicture();
    capture.complete(XFile('/tmp/capture.jpg'));
    final firstResult = await firstCapture;

    expect(secondCapture, isNull);
    expect(firstResult?.path, '/tmp/capture.jpg');
    expect(repository.takePictureCalls, 1);
    expect(provider.isCapturing, isFalse);
  });

  test(
    'inactive lifecycle disposes and resumed lifecycle reinitializes',
    () async {
      mockCameraPermission(isGranted: true);
      final provider = CameraProvider(repository);
      addTearDown(provider.dispose);
      await _waitForInitialization(provider);

      provider.didChangeAppLifecycleState(AppLifecycleState.inactive);
      await pumpEventQueue();
      expect(repository.disposeControllerCalls, 1);

      repository.zoomLimits = (1.5, 6.0);
      provider.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await _waitForInitialization(provider);

      expect(repository.reinitializeCalls, 1);
      expect(provider.currentZoom, 1.5);
    },
  );

  test(
    'resumed lifecycle waits for inactive disposal before reinitializing',
    () async {
      mockCameraPermission(isGranted: true);
      final provider = CameraProvider(repository);
      addTearDown(provider.dispose);
      await _waitForInitialization(provider);

      final disposeCompleter = Completer<void>();
      repository.disposeCompleter = disposeCompleter;

      provider.didChangeAppLifecycleState(AppLifecycleState.inactive);
      await pumpEventQueue();
      expect(repository.disposeControllerCalls, 1);

      repository.zoomLimits = (1.5, 6.0);
      provider.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await pumpEventQueue(times: 5);
      expect(repository.reinitializeCalls, 0);

      disposeCompleter.complete();
      await _waitForInitialization(provider);

      expect(repository.reinitializeCalls, 1);
      expect(provider.currentZoom, 1.5);
    },
  );
}

Future<void> _waitForInitialization(CameraProvider provider) async {
  await pumpEventQueue(times: 5);
  expect(provider.isLoading, isFalse);
}

class _FakeCameraRepository implements CameraRepository {
  @override
  CameraController? get controller => null;

  var initializeCalls = 0;
  var reinitializeCalls = 0;
  var toggleCameraDirectionCalls = 0;
  var disposeControllerCalls = 0;
  var takePictureCalls = 0;

  var zoomLimits = (1.0, 1.0);
  final zoomLevels = <double>[];

  Object? initializeError;
  Object? reinitializeError;
  Object? toggleCameraDirectionError;
  Completer<void>? disposeCompleter;
  Future<XFile?> takePictureResult = Future.value(XFile('/tmp/capture.jpg'));

  @override
  Future<void> initialize({CameraLensDirection direction = .back}) async {
    initializeCalls += 1;
    if (initializeError != null) throw initializeError!;
  }

  @override
  Future<(double minZoom, double maxZoom)> getZoomLimits() async => zoomLimits;

  @override
  Future<void> reinitialize() async {
    reinitializeCalls += 1;
    if (reinitializeError != null) throw reinitializeError!;
  }

  @override
  Future<void> toggleCameraDirection() async {
    toggleCameraDirectionCalls += 1;
    if (toggleCameraDirectionError != null) {
      throw toggleCameraDirectionError!;
    }
  }

  @override
  Future<void> disposeController() async {
    disposeControllerCalls += 1;
    final completer = disposeCompleter;
    if (completer != null) await completer.future;
  }

  @override
  Future<void> setZoomLevel(double zoom) async {
    zoomLevels.add(zoom);
  }

  @override
  Future<XFile?> takePicture() async {
    takePictureCalls += 1;
    return takePictureResult;
  }
}
