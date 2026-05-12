import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/features/camera/presentation/camera_provider.dart';
import 'package:framatic/features/camera/presentation/widgets/camera_error_widget.dart';
import 'package:framatic/features/camera/presentation/widgets/capture_button.dart';
import 'package:framatic/features/camera/presentation/widgets/frame_selector.dart';
import 'package:framatic/features/camera/presentation/widgets/zoom_slider.dart';
import 'package:framatic/features/frames_manager/presentation/frame_provider.dart';
import 'package:framatic/features/photo_preview/presentation/photo_preview_provider.dart';
import 'package:framatic/features/camera/presentation/camera_screen.dart';
import 'package:provider/provider.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

// Fake CameraProvider that avoids real camera initialization
// Uses noSuchMethod to handle WidgetsBindingObserver methods
class FakeCameraProvider extends ChangeNotifier
    with WidgetsBindingObserver
    implements CameraProvider {
  @override bool isLoading;
  @override bool isCapturing;
  @override AppError? error;
  @override CameraController? controller;
  @override double minZoom;
  @override double maxZoom;
  @override double currentZoom;

  bool retryCalled = false;
  bool switchCameraCalled = false;

  FakeCameraProvider({
    this.isLoading = false,
    this.isCapturing = false,
    this.error,
    this.controller,
    this.minZoom = 1.0,
    this.maxZoom = 3.0,
    this.currentZoom = 1.0,
  });

  @override
  Future<void> retry() async {
    retryCalled = true;
    notifyListeners();
  }

  @override
  Future<void> switchCamera() async {
    switchCameraCalled = true;
    notifyListeners();
  }

  @override
  Future<void> setZoomLevel(double zoom) async {
    currentZoom = zoom.clamp(minZoom, maxZoom);
    notifyListeners();
  }

  @override
  Future<XFile?> takePicture() async => null;
}
// ---- Fake FrameProvider ----

class FakeFrameProvider extends ChangeNotifier implements FrameProvider {
  @override List<Frame> frames;
  @override bool isLoading;
  int? _activeFrameId;

  FakeFrameProvider({
    List<Frame>? frames,
    this.isLoading = false,
    int? activeFrameId,
  })  : frames = frames ?? [],
        _activeFrameId = activeFrameId ?? frames?.firstOrNull?.id;

  @override
  Frame? get activeFrame => _activeFrameId == null
      ? null
      : frames.where((f) => f.id == _activeFrameId).firstOrNull;

  @override
  void setActiveFrame(int frameId) {
    _activeFrameId = frameId;
    notifyListeners();
  }

  @override Future<Frame> createFrame(Frame f) async => f;
  @override Future<Frame> updateFrame(Frame f) async => f;
  @override Future<void> deleteFrame(int id) async {}
  @override Future<void> orderFrames(int oldPos, int newPos) async {}
}

// ---- Fake PhotoPreviewProvider ----

class FakePhotoPreviewProvider extends ChangeNotifier
    implements PhotoPreviewProvider {
  @override bool isSaving = false;

  @override
  Future<String> processPhotoWithFrame({
    required String imagePath,
    required Frame frame,
  }) async => imagePath;

  @override Future<void> savePhoto(String imagePath) async {}
  @override void retakePhoto(String imagePath) {}
  @override String get successMessage => 'Saved';
}

// ---- Test helpers ----

Widget buildTestApp({
  required FakeCameraProvider cameraProvider,
  FakeFrameProvider? frameProvider,
  FakePhotoPreviewProvider? photoProvider,
}) {
  return SketchyApp(
    title: 'Test',
    home: MultiProvider(
      providers: [
        ChangeNotifierProvider<CameraProvider>.value(value: cameraProvider),
        ChangeNotifierProvider<FrameProvider>.value(
            value: frameProvider ?? FakeFrameProvider()),
        ChangeNotifierProvider<PhotoPreviewProvider>.value(
            value: photoProvider ?? FakePhotoPreviewProvider()),
      ],
      child: const CameraScreen(),
    ),
  );
}

void main() {
  // Direct CameraErrorWidget tests (no CameraController needed)
  group('CameraErrorWidget', () {
    Widget buildErrorApp(AppError? error, VoidCallback onRetry) {
      return SketchyApp(
        title: 'Test',
        home: CameraErrorWidget(error: error, onRetry: onRetry),
      );
    }

    testWidgets('shows error message', (tester) async {
      await tester.pumpWidget(buildErrorApp(
        const UnexpectedError("test error", userMessage: "Something went wrong"),
        () {},
      ));
      await tester.pump();

      expect(find.text("Something went wrong"), findsOneWidget);
    });

    testWidgets("shows 'Retry' button", (tester) async {
      await tester.pumpWidget(buildErrorApp(
        const UnexpectedError("test error", userMessage: "Something went wrong"),
        () {},
      ));
      await tester.pump();

      expect(find.text("Retry"), findsOneWidget);
    });

    testWidgets("tapping Retry calls onRetry callback", (tester) async {
      var called = false;
      await tester.pumpWidget(buildErrorApp(
        const UnexpectedError("test error", userMessage: "Something went wrong"),
        () => called = true,
      ));
      await tester.pump();

      await tester.tap(find.text("Retry"));
      await tester.pump();

      expect(called, isTrue);
    });

    testWidgets("shows fallback message when error is null", (tester) async {
      await tester.pumpWidget(buildErrorApp(null, () {}));
      await tester.pump();

      expect(find.text("An error occurred"), findsOneWidget);
    });
  });

  group("CameraScreen", () {
    testWidgets("shows SketchyCircularProgressIndicator when isLoading is true",
        (tester) async {
      final cameraProvider = FakeCameraProvider(isLoading: true);

      await tester.pumpWidget(buildTestApp(cameraProvider: cameraProvider));
      await tester.pump();

      expect(find.byType(SketchyCircularProgressIndicator), findsWidgets);
    });

    testWidgets("shows SketchyCircularProgressIndicator when controller is null",
        (tester) async {
      final cameraProvider = FakeCameraProvider(
        isLoading: false,
        controller: null,
      );

      await tester.pumpWidget(buildTestApp(cameraProvider: cameraProvider));
      await tester.pump();

      expect(find.byType(SketchyCircularProgressIndicator), findsWidgets);
    });

    testWidgets("ready state shows zoom slider, capture button, and frame selector",
        (tester) async {
      // CameraPreview renders Container() when the controller is not
      // initialized, so no platform view is created and this runs headlessly.
      const fakeDescription = CameraDescription(
        name: 'test_camera',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 0,
      );
      final fakeController = CameraController(fakeDescription, ResolutionPreset.low);
      addTearDown(fakeController.dispose);

      final frame = Frame(id: 1, title: '16:9', width: 16, height: 9);
      final cameraProvider = FakeCameraProvider(
        isLoading: false,
        controller: fakeController,
      );
      final frameProvider = FakeFrameProvider(
        frames: [frame],
        activeFrameId: 1,
      );

      await tester.pumpWidget(buildTestApp(
        cameraProvider: cameraProvider,
        frameProvider: frameProvider,
      ));
      await tester.pump();

      expect(find.byType(ZoomSlider), findsOneWidget);
      expect(find.byType(CaptureButton), findsOneWidget);
      expect(find.byType(FrameSelector), findsOneWidget);
    });
  });
}
