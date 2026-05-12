import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/core/widgets/circular_action_button.dart';
import 'package:framatic/features/photo_preview/presentation/photo_preview_provider.dart';
import 'package:framatic/features/photo_preview/presentation/photo_preview_screen.dart';
import 'package:provider/provider.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

class FakePhotoPreviewProvider extends ChangeNotifier
    implements PhotoPreviewProvider {
  @override
  bool isSaving;
  bool retakeCalled = false;
  bool saveCalled = false;

  FakePhotoPreviewProvider({this.isSaving = false});

  @override
  Future<String> processPhotoWithFrame({
    required String imagePath,
    required Frame frame,
  }) async =>
      imagePath;

  @override
  Future<void> savePhoto(String imagePath) async {
    saveCalled = true;
  }

  @override
  void retakePhoto(String imagePath) {
    retakeCalled = true;
  }

  @override
  String get successMessage => 'Photo saved';
}
File createTempJpeg() {
  final dir = Directory.systemTemp.createTempSync("framatic_test_");
  final file = File("${dir.path}/test.jpg");
  final bytes = Uint8List.fromList([
    0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
    0x01, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43,
    0x00, 0x08, 0x06, 0x06, 0x07, 0x06, 0x05, 0x08, 0x07, 0x07, 0x07, 0x09,
    0x09, 0x08, 0x0A, 0x0C, 0x14, 0x0D, 0x0C, 0x0B, 0x0B, 0x0C, 0x19, 0x12,
    0x13, 0x0F, 0x14, 0x1D, 0x1A, 0x1F, 0x1E, 0x1D, 0x1A, 0x1C, 0x1C, 0x20,
    0x24, 0x2E, 0x27, 0x20, 0x22, 0x2C, 0x23, 0x1C, 0x1C, 0x28, 0x37, 0x29,
    0x2C, 0x30, 0x31, 0x34, 0x34, 0x34, 0x1F, 0x27, 0x39, 0x3D, 0x38, 0x32,
    0x3C, 0x2E, 0x33, 0x34, 0x32, 0xFF, 0xC0, 0x00, 0x0B, 0x08, 0x00, 0x01,
    0x00, 0x01, 0x01, 0x01, 0x11, 0x00, 0xFF, 0xC4, 0x00, 0x1F, 0x00, 0x00,
    0x01, 0x05, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
    0x09, 0x0A, 0x0B, 0xFF, 0xDA, 0x00, 0x08, 0x01, 0x01, 0x00, 0x00, 0x3F,
    0x00, 0xFB, 0xD4, 0xFF, 0xD9,
  ]);
  file.writeAsBytesSync(bytes);
  return file;
}

Widget buildTestApp(String imagePath,
    {FakePhotoPreviewProvider? provider}) {
  return ChangeNotifierProvider<PhotoPreviewProvider>.value(
    value: provider ?? FakePhotoPreviewProvider(),
    child: SketchyApp(
      title: 'Test',
      home: PhotoPreviewScreen(imagePath: imagePath),
    ),
  );
}
void main() {
  late File testImageFile;

  setUp(() {
    testImageFile = createTempJpeg();
  });

  tearDown(() {
    if (testImageFile.existsSync()) testImageFile.deleteSync();
    testImageFile.parent.deleteSync(recursive: true);
  });

  group('PhotoPreviewScreen', () {
    testWidgets('renders Save and Retake CircularActionButtons',
        (tester) async {
      await tester.pumpWidget(buildTestApp(testImageFile.path));
      await tester.pump();

      expect(find.byType(CircularActionButton), findsNWidgets(2));
    });

    testWidgets('renders Retake and Save labels', (tester) async {
      await tester.pumpWidget(buildTestApp(testImageFile.path));
      await tester.pump();

      expect(find.text('Retake'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('buttons have null onPressed when isSaving is true',
        (tester) async {
      final provider = FakePhotoPreviewProvider(isSaving: true);
      await tester.pumpWidget(
          buildTestApp(testImageFile.path, provider: provider));
      await tester.pump();

      final buttons = tester
          .widgetList<CircularActionButton>(find.byType(CircularActionButton))
          .toList();
      expect(buttons, hasLength(2));
      for (final btn in buttons) {
        expect(btn.onPressed, isNull);
      }
    });

    testWidgets('buttons are enabled when isSaving is false',
        (tester) async {
      final provider = FakePhotoPreviewProvider();
      await tester.pumpWidget(
          buildTestApp(testImageFile.path, provider: provider));
      await tester.pump();

      final buttons = tester
          .widgetList<CircularActionButton>(find.byType(CircularActionButton))
          .toList();
      expect(buttons, hasLength(2));
      for (final btn in buttons) {
        expect(btn.onPressed, isNotNull);
      }
    });

    testWidgets('tapping Retake calls provider.retakePhoto',
        (tester) async {
      final provider = FakePhotoPreviewProvider();
      await tester.pumpWidget(
          buildTestApp(testImageFile.path, provider: provider));
      await tester.pump();

      await tester.tap(find.text('Retake'));
      await tester.pump();

      expect(provider.retakeCalled, isTrue);
    });

    testWidgets('tapping Retake pops the route', (tester) async {
      final provider = FakePhotoPreviewProvider();
      await tester.pumpWidget(
        ChangeNotifierProvider<PhotoPreviewProvider>.value(
          value: provider,
          child: SketchyApp(
            title: 'Test',
            home: Builder(
              builder: (ctx) => GestureDetector(
                onTap: () => Navigator.of(ctx).push(
                  SketchyPageRoute(
                    builder: (_) =>
                        PhotoPreviewScreen(imagePath: testImageFile.path),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Retake'), findsOneWidget);

      await tester.tap(find.text('Retake'));
      await tester.pumpAndSettle();

      expect(find.text('Retake'), findsNothing);
    });
  });
}
