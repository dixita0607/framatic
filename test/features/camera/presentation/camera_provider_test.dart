import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/features/camera/data/camera_repository.dart';
import 'package:framatic/features/camera/domain/camera_error.dart';
import 'package:framatic/features/camera/presentation/camera_provider.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class FakeCameraRepository implements CameraRepository {
  @override
  CameraController? controller;

  double minZoom;
  double maxZoom;
  Exception? errorOnToggle;
  Exception? errorOnInitialize;

  bool initializeCalled = false;
  bool toggleCalled = false;
  bool disposeCalled = false;
  double? lastZoomSet;
  int takePictureCallCount = 0;
  XFile? pictureToReturn;

  FakeCameraRepository({
    this.minZoom = 1.0,
    this.maxZoom = 5.0,
    this.pictureToReturn,
  });

  @override
  Future<void> initialize({
    CameraLensDirection direction = CameraLensDirection.back,
  }) async {
    if (errorOnInitialize != null) throw errorOnInitialize!;
    initializeCalled = true;
  }

  @override
  Future<(double, double)> getZoomLimits() async => (minZoom, maxZoom);

  @override
  Future<void> reinitialize() async {}

  @override
  Future<void> toggleCameraDirection() async {
    if (errorOnToggle != null) throw errorOnToggle!;
    toggleCalled = true;
  }

  @override
  Future<void> disposeController() async {
    disposeCalled = true;
  }

  @override
  Future<void> setZoomLevel(double zoom) async {
    lastZoomSet = zoom;
  }

  @override
  Future<XFile?> takePicture() async {
    takePictureCallCount++;
    return pictureToReturn;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Mock the permission_handler platform channel to report camera as granted.
///
/// - `checkPermissionStatus` expects a single int back.
///   PermissionStatus enum: denied=0, granted=1, ...
/// - `requestPermissions` expects Map<int, int> back: {permissionValue: status}.
void _mockPermissionChannelGranted() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('flutter.baseflow.com/permissions/methods'),
    (call) async {
      if (call.method == 'checkPermissionStatus') {
        return 1; // PermissionStatus.granted (index 1)
      }
      if (call.method == 'requestPermissions') {
        // arguments is a List of permission values; return all as granted
        final args = call.arguments as List<dynamic>;
        return <int, int>{for (final v in args) (v as int): 1};
      }
      return null;
    },
  );
}

void _clearPermissionChannelMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('flutter.baseflow.com/permissions/methods'),
    null,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(_mockPermissionChannelGranted);
  tearDown(_clearPermissionChannelMock);

  group('CameraProvider', () {
    group('setZoomLevel', () {
      test('clamps zoom value below minZoom up to minZoom', () async {
        final repo = FakeCameraRepository(minZoom: 1.0, maxZoom: 5.0);
        final provider = CameraProvider(repo);
        addTearDown(provider.dispose);
        await pumpEventQueue();

        await provider.setZoomLevel(0.5);

        expect(repo.lastZoomSet, 1.0);
        expect(provider.currentZoom, 1.0);
      });

      test('clamps zoom value above maxZoom down to maxZoom', () async {
        final repo = FakeCameraRepository(minZoom: 1.0, maxZoom: 5.0);
        final provider = CameraProvider(repo);
        addTearDown(provider.dispose);
        await pumpEventQueue();

        await provider.setZoomLevel(10.0);

        expect(repo.lastZoomSet, 5.0);
        expect(provider.currentZoom, 5.0);
      });

      test('passes through zoom value within valid range', () async {
        final repo = FakeCameraRepository(minZoom: 1.0, maxZoom: 5.0);
        final provider = CameraProvider(repo);
        addTearDown(provider.dispose);
        await pumpEventQueue();

        await provider.setZoomLevel(3.0);

        expect(repo.lastZoomSet, 3.0);
        expect(provider.currentZoom, 3.0);
      });

      test('exactly at minZoom passes through unchanged', () async {
        final repo = FakeCameraRepository(minZoom: 1.0, maxZoom: 5.0);
        final provider = CameraProvider(repo);
        addTearDown(provider.dispose);
        await pumpEventQueue();

        await provider.setZoomLevel(1.0);

        expect(repo.lastZoomSet, 1.0);
      });

      test('exactly at maxZoom passes through unchanged', () async {
        final repo = FakeCameraRepository(minZoom: 1.0, maxZoom: 5.0);
        final provider = CameraProvider(repo);
        addTearDown(provider.dispose);
        await pumpEventQueue();

        await provider.setZoomLevel(5.0);

        expect(repo.lastZoomSet, 5.0);
      });
    });

    group('takePicture', () {
      test('sets isCapturing to true during call and resets to false after', () async {
        final repo = FakeCameraRepository();
        final provider = CameraProvider(repo);
        addTearDown(provider.dispose);
        await pumpEventQueue();

        bool capturedDuring = false;
        provider.addListener(() {
          if (provider.isCapturing) capturedDuring = true;
        });

        await provider.takePicture();

        expect(capturedDuring, isTrue);
        expect(provider.isCapturing, isFalse);
      });

      test('returns null when already isCapturing without calling repo again', () async {
        final repo = FakeCameraRepository();
        final provider = CameraProvider(repo);
        addTearDown(provider.dispose);
        await pumpEventQueue();

        // Start the first capture; do NOT await it yet so isCapturing stays true
        final firstFuture = provider.takePicture();
        // Call again immediately while first is in progress
        final secondResult = await provider.takePicture();

        await firstFuture;

        expect(secondResult, isNull);
        expect(repo.takePictureCallCount, 1);
      });

      test('isCapturing is false after successful takePicture', () async {
        final repo = FakeCameraRepository();
        final provider = CameraProvider(repo);
        addTearDown(provider.dispose);
        await pumpEventQueue();

        await provider.takePicture();

        expect(provider.isCapturing, isFalse);
      });
    });

    group('switchCamera', () {
      test('sets isLoading during operation and clears after', () async {
        final repo = FakeCameraRepository();
        final provider = CameraProvider(repo);
        addTearDown(provider.dispose);
        await pumpEventQueue();

        bool loadingDuringSwitch = false;
        provider.addListener(() {
          if (provider.isLoading) loadingDuringSwitch = true;
        });

        await provider.switchCamera();

        expect(loadingDuringSwitch, isTrue);
        expect(provider.isLoading, isFalse);
      });

      test('clears isLoading after successful switchCamera', () async {
        final repo = FakeCameraRepository();
        final provider = CameraProvider(repo);
        addTearDown(provider.dispose);
        await pumpEventQueue();

        await provider.switchCamera();

        expect(provider.isLoading, isFalse);
      });

      test('sets error and clears isLoading when repo throws CameraError', () async {
        final repo = FakeCameraRepository();
        repo.errorOnToggle = SwitchCameraError(
          'hardware error',
          userMessage: 'Failed to switch camera.',
        );
        final provider = CameraProvider(repo);
        addTearDown(provider.dispose);
        await pumpEventQueue();

        await provider.switchCamera();

        expect(provider.error, isA<SwitchCameraError>());
        expect(provider.isLoading, isFalse);
      });

      test('sets SwitchCameraError when repo throws generic exception', () async {
        final repo = FakeCameraRepository();
        repo.errorOnToggle = Exception('unexpected');
        final provider = CameraProvider(repo);
        addTearDown(provider.dispose);
        await pumpEventQueue();

        await provider.switchCamera();

        expect(provider.error, isA<SwitchCameraError>());
      });
    });
  });
}
