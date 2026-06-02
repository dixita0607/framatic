import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';
import 'package:framatic/features/camera/presentation/camera_provider.dart';
import 'package:framatic/features/camera/presentation/camera_screen.dart';
import 'package:framatic/features/frames_manager/data/frame_repository.dart';
import 'package:framatic/features/frames_manager/presentation/frame_provider.dart';
import 'package:provider/provider.dart';

import '../../../helpers/widget_test_app.dart';

void main() {
  group('CameraScreen', () {
    testWidgets('shows progress while the camera has no usable controller', (
      tester,
    ) async {
      final frameProvider = FrameProvider(
        _FakeFrameRepository(
          frames: [Frame(id: 1, title: '4:3', width: 4, height: 3)],
          order: ['1'],
        ),
      );
      addTearDown(frameProvider.dispose);

      await tester.pumpWidget(
        sketchTestApp(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<CameraProvider>.value(
                value: _FakeCameraProvider(),
              ),
              ChangeNotifierProvider<FrameProvider>.value(value: frameProvider),
            ],
            child: const CameraScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SketchProgress), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows camera errors even when the controller is missing', (
      tester,
    ) async {
      final frameProvider = FrameProvider(
        _FakeFrameRepository(
          frames: [Frame(id: 1, title: '4:3', width: 4, height: 3)],
          order: ['1'],
        ),
      );
      addTearDown(frameProvider.dispose);

      await tester.pumpWidget(
        sketchTestApp(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<CameraProvider>.value(
                value: _FakeCameraProvider(
                  isLoading: false,
                  error: const PermissionError(
                    'Camera denied',
                    userMessage: 'Camera permission is required.',
                  ),
                ),
              ),
              ChangeNotifierProvider<FrameProvider>.value(value: frameProvider),
            ],
            child: const CameraScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Camera permission is required.'), findsOneWidget);
      expect(find.byType(SketchProgress), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}

class _FakeCameraProvider extends ChangeNotifier implements CameraProvider {
  _FakeCameraProvider({bool isLoading = true, AppError? error})
    : _isLoading = isLoading,
      _error = error;

  final bool _isLoading;
  final AppError? _error;

  @override
  bool get isLoading => _isLoading;

  @override
  bool get isCapturing => false;

  @override
  AppError? get error => _error;

  @override
  CameraController? get controller => null;

  @override
  double get minZoom => 1;

  @override
  double get maxZoom => 1;

  @override
  double get currentZoom => 1;

  @override
  Future<void> retry() async {}

  @override
  Future<void> setZoomLevel(double zoom) async {}

  @override
  Future<void> switchCamera() async {}

  @override
  Future<XFile?> takePicture() async => null;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFrameRepository implements FrameRepository {
  _FakeFrameRepository({
    required List<Frame> frames,
    List<String> order = const [],
  }) : _frames = List.of(frames),
       _order = List.of(order);

  final List<Frame> _frames;
  var _order = <String>[];

  @override
  Future<List<Frame>> getAllFrames() async => List.of(_frames);

  @override
  Future<List<String>> getOrder() async => List.of(_order);

  @override
  Future<void> setOrder(List<String> order) async {
    _order = List.of(order);
  }

  @override
  Future<Frame> createFrame(Frame frame) async => frame;

  @override
  Future<Frame> updateFrame(Frame frame) async => frame;

  @override
  Future<int> deleteFrame(int id) async => id;
}
