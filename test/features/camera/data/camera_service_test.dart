import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/features/camera/data/camera_service.dart';
import 'package:framatic/features/camera/domain/camera_error.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CameraPlatform originalPlatform;
  late _FakeCameraPlatform platform;

  setUp(() {
    originalPlatform = CameraPlatform.instance;
    platform = _FakeCameraPlatform();
    CameraPlatform.instance = platform;
  });

  tearDown(() {
    CameraPlatform.instance = originalPlatform;
  });

  test(
    'initialize throws a domain error when no cameras are available',
    () async {
      platform.cameras = [];

      await expectLater(
        CameraService().initialize(),
        throwsA(isA<NoCameraAvailableError>()),
      );
    },
  );

  test(
    'initialize creates the requested camera and stores zoom limits',
    () async {
      platform
        ..cameras = [_backCamera, _frontCamera]
        ..minZoom = 0.5
        ..maxZoom = 4.0;

      final service = CameraService();
      await service.initialize(direction: CameraLensDirection.back);

      expect(service.controller, isNotNull);
      expect(service.controller!.value.isInitialized, isTrue);
      expect(platform.createdDescriptions, [_backCamera]);
      expect(await service.getZoomLimits(), (0.5, 4.0));
      expect(platform.zoomLevels, [(1, 0.5)]);
    },
  );

  test(
    'initialize falls back to first camera when direction is unavailable',
    () async {
      platform.cameras = [_frontCamera];

      final service = CameraService();
      await service.initialize(direction: CameraLensDirection.back);

      expect(platform.createdDescriptions, [_frontCamera]);
    },
  );

  test('setZoomLevel clamps to initialized zoom limits', () async {
    platform
      ..cameras = [_backCamera]
      ..minZoom = 1.0
      ..maxZoom = 3.0;
    final service = CameraService();
    await service.initialize();
    platform.zoomLevels.clear();

    await service.setZoomLevel(99);
    await service.setZoomLevel(0);

    expect(platform.zoomLevels, [(1, 3.0), (1, 1.0)]);
  });

  test('setZoomLevel is a no-op before initialization', () async {
    await CameraService().setZoomLevel(2);

    expect(platform.zoomLevels, isEmpty);
  });

  test('toggleCameraDirection switches between available cameras', () async {
    platform.cameras = [_backCamera, _frontCamera];
    final service = CameraService();
    await service.initialize(direction: CameraLensDirection.back);

    await service.toggleCameraDirection();

    expect(platform.createdDescriptions, [_backCamera, _frontCamera]);
    expect(platform.disposedCameraIds, [1]);
    expect(service.controller!.description, _frontCamera);
  });

  test('toggleCameraDirection is a no-op with one camera', () async {
    platform.cameras = [_backCamera];
    final service = CameraService();
    await service.initialize();

    await service.toggleCameraDirection();

    expect(platform.createdDescriptions, [_backCamera]);
    expect(service.controller!.description, _backCamera);
  });

  test('reinitialize requires previously discovered cameras', () async {
    await expectLater(
      CameraService().reinitialize(),
      throwsA(isA<ReinitializeCameraError>()),
    );
  });

  test('reinitialize restores the current camera direction', () async {
    platform.cameras = [_backCamera, _frontCamera];
    final service = CameraService();
    await service.initialize(direction: CameraLensDirection.front);
    await service.disposeController();

    await service.reinitialize();

    expect(platform.createdDescriptions, [_frontCamera, _backCamera]);
    expect(service.controller!.description, _backCamera);
  });

  test('takePicture returns null before initialization', () async {
    expect(await CameraService().takePicture(), isNull);
  });

  test('takePicture returns the captured file after initialization', () async {
    platform
      ..cameras = [_backCamera]
      ..capturedFile = XFile('/tmp/captured.jpg');
    final service = CameraService();
    await service.initialize();

    final file = await service.takePicture();

    expect(file?.path, '/tmp/captured.jpg');
    expect(platform.takePictureCameraIds, [1]);
  });

  test('takePicture wraps capture failures', () async {
    platform
      ..cameras = [_backCamera]
      ..takePictureError = PlatformException(code: 'capture_failed');
    final service = CameraService();
    await service.initialize();

    await expectLater(
      service.takePicture(),
      throwsA(isA<CaptureCameraError>()),
    );
  });

  test('disposeController releases the current controller', () async {
    platform.cameras = [_backCamera];
    final service = CameraService();
    await service.initialize();

    await service.disposeController();

    expect(platform.disposedCameraIds, [1]);
    expect(service.controller, isNull);
  });
}

const _backCamera = CameraDescription(
  name: 'back',
  lensDirection: CameraLensDirection.back,
  sensorOrientation: 90,
);

const _frontCamera = CameraDescription(
  name: 'front',
  lensDirection: CameraLensDirection.front,
  sensorOrientation: 270,
);

class _FakeCameraPlatform extends CameraPlatform {
  List<CameraDescription> cameras = [_backCamera];
  final List<CameraDescription> createdDescriptions = [];
  final List<int> disposedCameraIds = [];
  final List<(int cameraId, double zoom)> zoomLevels = [];
  final List<int> takePictureCameraIds = [];

  double minZoom = 1.0;
  double maxZoom = 1.0;
  XFile capturedFile = XFile('/tmp/capture.jpg');
  Object? takePictureError;

  var _nextCameraId = 1;
  final _initializedControllers =
      <int, StreamController<CameraInitializedEvent>>{};
  final _errorControllers = <int, StreamController<CameraErrorEvent>>{};
  final _descriptionById = <int, CameraDescription>{};

  @override
  Future<List<CameraDescription>> availableCameras() async => cameras;

  @override
  Future<int> createCamera(
    CameraDescription cameraDescription,
    ResolutionPreset? resolutionPreset, {
    bool enableAudio = false,
  }) async {
    final id = _nextCameraId++;
    createdDescriptions.add(cameraDescription);
    _descriptionById[id] = cameraDescription;
    return id;
  }

  @override
  Future<void> initializeCamera(
    int cameraId, {
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) async {
    _initializedControllers[cameraId]?.add(
      CameraInitializedEvent(
        cameraId,
        1920,
        1080,
        ExposureMode.auto,
        true,
        FocusMode.auto,
        true,
      ),
    );
  }

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) {
    return (_initializedControllers[cameraId] ??=
            StreamController<CameraInitializedEvent>.broadcast())
        .stream;
  }

  @override
  Stream<CameraErrorEvent> onCameraError(int cameraId) {
    return (_errorControllers[cameraId] ??=
            StreamController<CameraErrorEvent>.broadcast())
        .stream;
  }

  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() {
    return const Stream<DeviceOrientationChangedEvent>.empty();
  }

  @override
  Future<double> getMinZoomLevel(int cameraId) async => minZoom;

  @override
  Future<double> getMaxZoomLevel(int cameraId) async => maxZoom;

  @override
  Future<void> setZoomLevel(int cameraId, double zoom) async {
    zoomLevels.add((cameraId, zoom));
  }

  @override
  Future<XFile> takePicture(int cameraId) async {
    takePictureCameraIds.add(cameraId);
    final error = takePictureError;
    if (error != null) throw error;
    return capturedFile;
  }

  @override
  Future<void> dispose(int cameraId) async {
    disposedCameraIds.add(cameraId);
    _descriptionById.remove(cameraId);
  }

  @override
  Widget buildPreview(int cameraId) {
    throw UnimplementedError('Preview is not used by CameraService tests.');
  }
}
