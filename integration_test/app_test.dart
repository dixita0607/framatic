import 'dart:io';

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
import 'package:framatic/features/frames_manager/presentation/widgets/frame_list_item.dart';
import 'package:framatic/features/photo_preview/data/photo_repository.dart';
import 'package:framatic/features/photo_preview/presentation/photo_preview_provider.dart';
import 'package:framatic/features/photo_preview/presentation/photo_preview_screen.dart';
import 'package:image/image.dart' as img;
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Google Play beta smoke flows', () {
    testWidgets('camera shell renders with built-in frame controls', (
      tester,
    ) async {
      final harness = _BetaHarness();
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.cameraApp());
      await _settleProvider(tester);

      expect(
        find.byKey(const ValueKey('test_camera_viewfinder')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('capture_button')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('frame_manager_button')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('frame_selector')), findsOneWidget);
      expect(find.byKey(const ValueKey('frame_selector_1')), findsOneWidget);
      expect(find.byKey(const ValueKey('frame_selector_2')), findsOneWidget);
      expect(find.byKey(const ValueKey('frame_selector_3')), findsOneWidget);
      expect(find.text('4:3'), findsOneWidget);
      expect(find.text('16:9'), findsOneWidget);
      expect(find.text('1:1'), findsOneWidget);
    });

    testWidgets('built-in frames are locked and reorderable', (tester) async {
      final harness = _BetaHarness();
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.cameraApp());
      await _settleProvider(tester);
      await tester.tap(find.byKey(const ValueKey('frame_manager_button')));
      await tester.pumpAndSettle();

      expect(find.byType(FrameListItem), findsNWidgets(3));
      expect(find.text('Built-in'), findsNWidgets(3));
      expect(find.byKey(const ValueKey('edit_custom_frame_1')), findsNothing);
      expect(find.byKey(const ValueKey('delete_custom_frame_1')), findsNothing);

      tester
          .widget<ReorderableList>(find.byType(ReorderableList))
          .onReorderItem!
          .call(0, 2);
      await _settleProvider(tester);

      expect(harness.frameProvider.frames.map((frame) => frame.title), [
        '16:9',
        '1:1',
        '4:3',
      ]);
      expect(harness.frameRepository.setOrderCalls.last, ['2', '3', '1']);
    });

    testWidgets('custom frame can be created, edited, and deleted', (
      tester,
    ) async {
      final harness = _BetaHarness();
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.cameraApp());
      await _settleProvider(tester);
      await tester.tap(find.byKey(const ValueKey('frame_manager_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('add_custom_frame_button')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText).at(0), '  Cinema  ');
      await tester.enterText(find.byType(EditableText).at(1), '21');
      await tester.enterText(find.byType(EditableText).at(2), '9');
      await tester.tap(find.text('Save'));
      await _settleProviderAndAnimations(tester);

      expect(harness.frameRepository.createdFrames.single.title, 'Cinema');
      expect(find.text('Cinema'), findsOneWidget);
      expect(find.text('21:9'), findsOneWidget);

      final customFrameId = harness.frameRepository.createdFrames.single.id!;
      await tester.tap(
        find.byKey(ValueKey('edit_custom_frame_$customFrameId')),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText).at(0), 'Story Frame');
      await tester.enterText(find.byType(EditableText).at(1), '4');
      await tester.enterText(find.byType(EditableText).at(2), '5');
      await tester.tap(find.text('Save'));
      await _settleProviderAndAnimations(tester);

      expect(harness.frameRepository.updatedFrames.single.title, 'Story Frame');
      expect(find.text('Story Frame'), findsOneWidget);
      expect(find.text('4:5'), findsOneWidget);

      await tester.tap(
        find.byKey(ValueKey('delete_custom_frame_$customFrameId')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await _settleProviderAndAnimations(tester);

      expect(harness.frameRepository.deletedIds, [customFrameId]);
      expect(find.text('Story Frame'), findsNothing);
    });

    testWidgets('preview discard and save return to the launching flow', (
      tester,
    ) async {
      final imageFile = _createPreviewImage();
      final photoProvider = _FakePhotoPreviewProvider();
      final results = <bool?>[];

      await tester.pumpWidget(
        _previewApp(
          provider: photoProvider,
          imagePath: imageFile.path,
          onResult: results.add,
        ),
      );

      await tester.tap(find.text('Open preview'));
      await tester.pumpAndSettle();
      await _settleFileImage(tester);
      await tester.tap(find.byKey(const ValueKey('preview_discard_button')));
      await tester.pumpAndSettle();

      expect(photoProvider.retakenPaths, [imageFile.path]);
      expect(results, [false]);

      await tester.tap(find.text('Open preview'));
      await tester.pumpAndSettle();
      await _settleFileImage(tester);
      await tester.tap(find.byKey(const ValueKey('preview_save_button')));
      await tester.pumpAndSettle();

      expect(photoProvider.savedPaths, [imageFile.path]);
      expect(results, [false, true]);
    });
  });
}

class _BetaHarness {
  _BetaHarness()
    : frameRepository = _FakeFrameRepository(
        frames: [
          _frame(id: 1, title: '4:3', width: 4, height: 3),
          _frame(id: 2, title: '16:9', width: 16, height: 9),
          _frame(id: 3, title: '1:1', width: 1, height: 1),
        ],
        order: ['1', '2', '3'],
      ) {
    frameProvider = FrameProvider(frameRepository);
  }

  final _FakeFrameRepository frameRepository;
  final _FakeCameraProvider cameraProvider = _FakeCameraProvider();
  final _FakePhotoPreviewProvider photoProvider = _FakePhotoPreviewProvider();
  late final FrameProvider frameProvider;

  Widget cameraApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CameraProvider>.value(value: cameraProvider),
        ChangeNotifierProvider<FrameProvider>.value(value: frameProvider),
        ChangeNotifierProvider<PhotoPreviewProvider>.value(
          value: photoProvider,
        ),
      ],
      child: _testApp(
        CameraScreen(
          cameraViewportBuilder: (context, activeFrame) {
            return Center(
              child: Text(
                'Test viewfinder for ${activeFrame.title}',
                key: const ValueKey('test_camera_viewfinder'),
              ),
            );
          },
        ),
      ),
    );
  }

  void dispose() {
    cameraProvider.dispose();
    frameProvider.dispose();
    photoProvider.dispose();
  }
}

Widget _testApp(Widget home) {
  const theme = SketchThemeCatalog.graphiteLight;
  return SketchTheme(
    data: theme,
    child: WidgetsApp(
      color: theme.background,
      textStyle: theme.bodyText,
      pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
      ),
      home: DefaultTextStyle(style: theme.bodyText, child: home),
    ),
  );
}

Widget _previewApp({
  required _FakePhotoPreviewProvider provider,
  required String imagePath,
  required ValueChanged<bool?> onResult,
}) {
  return ChangeNotifierProvider<PhotoPreviewProvider>.value(
    value: provider,
    child: _testApp(_PreviewLauncher(imagePath: imagePath, onResult: onResult)),
  );
}

class _PreviewLauncher extends StatelessWidget {
  const _PreviewLauncher({required this.imagePath, required this.onResult});

  final String imagePath;
  final ValueChanged<bool?> onResult;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SketchButton(
        label: 'Open preview',
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            sketchPageRoute(
              (context) => PhotoPreviewScreen(imagePath: imagePath),
            ),
          );
          onResult(result);
        },
      ),
    );
  }
}

Frame _frame({
  required int id,
  required String title,
  required int width,
  required int height,
  bool isCustom = false,
}) {
  return Frame(
    id: id,
    title: title,
    width: width,
    height: height,
    isCustom: isCustom,
  );
}

File _createPreviewImage() {
  final directory = Directory.systemTemp.createTempSync(
    'framatic_integration_preview_',
  );
  final file = File('${directory.path}/preview.jpg');
  addTearDown(() => directory.delete(recursive: true));

  final image = img.Image(width: 2, height: 2);
  img.fill(image, color: img.ColorRgb8(255, 255, 255));
  file.writeAsBytesSync(img.encodeJpg(image));
  return file;
}

Future<void> _settleProvider(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump();
  }
}

Future<void> _settleProviderAndAnimations(WidgetTester tester) async {
  await _settleProvider(tester);
  await tester.pump(const Duration(milliseconds: 200));
}

Future<void> _settleFileImage(WidgetTester tester) async {
  await tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  });
  await tester.pump();
}

class _FakeCameraProvider extends ChangeNotifier implements CameraProvider {
  @override
  bool get isLoading => false;

  @override
  bool get isCapturing => false;

  @override
  AppError? get error => null;

  @override
  CameraController? get controller => null;

  @override
  double get minZoom => 1;

  @override
  double get maxZoom => 4;

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
  final List<Frame> createdFrames = [];
  final List<Frame> updatedFrames = [];
  final List<int> deletedIds = [];
  final List<List<String>> setOrderCalls = [];

  var _order = <String>[];
  var _nextId = 100;

  @override
  Future<List<Frame>> getAllFrames() async => List.of(_frames);

  @override
  Future<List<String>> getOrder() async => List.of(_order);

  @override
  Future<void> setOrder(List<String> order) async {
    _order = List.of(order);
    setOrderCalls.add(List.of(order));
  }

  @override
  Future<Frame> createFrame(Frame frame) async {
    final createdFrame = frame.copyWith(id: frame.id ?? _nextId++);
    createdFrames.add(createdFrame);
    _frames.add(createdFrame);
    return createdFrame;
  }

  @override
  Future<Frame> updateFrame(Frame frame) async {
    updatedFrames.add(frame);
    final index = _frames.indexWhere((existing) => existing.id == frame.id);
    if (index != -1) {
      _frames[index] = frame;
    }
    return frame;
  }

  @override
  Future<int> deleteFrame(int id) async {
    deletedIds.add(id);
    _frames.removeWhere((frame) => frame.id == id);
    return id;
  }
}

class _FakePhotoPreviewProvider extends PhotoPreviewProvider {
  _FakePhotoPreviewProvider() : super(_FakePhotoRepository());

  final List<String> savedPaths = [];
  final List<String> retakenPaths = [];
  var _isSaving = false;

  @override
  bool get isSaving => _isSaving;

  @override
  Future<void> savePhoto(String imagePath) async {
    savedPaths.add(imagePath);
    _isSaving = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    _isSaving = false;
    notifyListeners();
  }

  @override
  void retakePhoto(String imagePath) {
    retakenPaths.add(imagePath);
  }
}

class _FakePhotoRepository implements PhotoRepository {
  @override
  Future<String> processPhotoWithFrame({
    required String imagePath,
    required Frame frame,
  }) async {
    return imagePath;
  }

  @override
  Future<void> saveToGallery(String imagePath) async {}
}
