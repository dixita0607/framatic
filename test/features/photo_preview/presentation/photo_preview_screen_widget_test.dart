import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';
import 'package:framatic/core/widgets/circular_action_button.dart';
import 'package:framatic/features/photo_preview/data/photo_repository.dart';
import 'package:framatic/features/photo_preview/presentation/photo_preview_provider.dart';
import 'package:framatic/features/photo_preview/presentation/photo_preview_screen.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';

import '../../../helpers/widget_test_app.dart';

void main() {
  group('PhotoPreviewScreen', () {
    testWidgets('shows the processed photo and action buttons', (tester) async {
      final imageFile = _createPreviewImage();
      final provider = _FakePhotoPreviewProvider();

      await _pumpWidgetWithFileImage(
        tester,
        ChangeNotifierProvider<PhotoPreviewProvider>.value(
          value: provider,
          child: buildTestApp(PhotoPreviewScreen(imagePath: imageFile.path)),
        ),
      );
      await _settleFileImage(tester);

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Retake'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.byType(SketchProgress), findsNothing);
    });

    testWidgets('retakes by deleting the preview path and popping false', (
      tester,
    ) async {
      final imageFile = _createPreviewImage();
      final provider = _FakePhotoPreviewProvider();
      bool? routeResult;

      await tester.pumpWidget(
        _launchingApp(
          provider: provider,
          imagePath: imageFile.path,
          onResult: (result) => routeResult = result,
        ),
      );

      await tester.tap(find.text('Open preview'));
      await tester.pumpAndSettle();
      await _settleFileImage(tester);
      await tester.tap(find.widgetWithText(CircularActionButton, 'Retake'));
      await tester.pumpAndSettle();

      expect(provider.retakenPaths, [imageFile.path]);
      expect(provider.savedPaths, isEmpty);
      expect(routeResult, isFalse);
      expect(find.text('Open preview'), findsOneWidget);
    });

    testWidgets('saves through the provider and returns immediately', (
      tester,
    ) async {
      final imageFile = _createPreviewImage();
      final provider = _FakePhotoPreviewProvider();
      bool? routeResult;

      await tester.pumpWidget(
        _launchingApp(
          provider: provider,
          imagePath: imageFile.path,
          onResult: (result) => routeResult = result,
        ),
      );

      await tester.tap(find.text('Open preview'));
      await tester.pumpAndSettle();
      await _settleFileImage(tester);
      await tester.tap(find.widgetWithText(CircularActionButton, 'Save'));
      await tester.pumpAndSettle();

      expect(provider.savedPaths, [imageFile.path]);
      expect(provider.retakenPaths, isEmpty);
      expect(routeResult, isTrue);
      expect(find.text('Open preview'), findsOneWidget);
      expect(find.text('Done'), findsNothing);
      expect(find.text('Saved test photo'), findsNothing);

      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('disables actions and shows progress while saving', (
      tester,
    ) async {
      final imageFile = _createPreviewImage();
      final provider = _FakePhotoPreviewProvider(isSaving: true);
      bool? routeResult;

      await tester.pumpWidget(
        _launchingApp(
          provider: provider,
          imagePath: imageFile.path,
          onResult: (result) => routeResult = result,
        ),
      );

      await tester.tap(find.text('Open preview'));
      await tester.pump(const Duration(milliseconds: 200));
      await _settleFileImage(tester);

      expect(find.byType(SketchProgress), findsOneWidget);

      await tester.tap(find.widgetWithText(CircularActionButton, 'Save'));
      await tester.tap(find.widgetWithText(CircularActionButton, 'Retake'));
      await tester.pump();

      expect(provider.savedPaths, isEmpty);
      expect(provider.retakenPaths, isEmpty);
      expect(routeResult, isNull);
    });
  });
}

Future<void> _pumpWidgetWithFileImage(
  WidgetTester tester,
  Widget widget,
) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(widget);
  });
}

Future<void> _settleFileImage(WidgetTester tester) async {
  await tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  });
  await tester.pump();
}

Widget _launchingApp({
  required _FakePhotoPreviewProvider provider,
  required String imagePath,
  required ValueChanged<bool?> onResult,
}) {
  return ChangeNotifierProvider<PhotoPreviewProvider>.value(
    value: provider,
    child: buildTestApp(
      _PreviewLauncher(imagePath: imagePath, onResult: onResult),
    ),
  );
}

File _createPreviewImage() {
  final directory = Directory.systemTemp.createTempSync(
    'framatic_preview_test_',
  );
  final file = File('${directory.path}/preview.jpg');
  addTearDown(() => directory.delete(recursive: true));

  final image = img.Image(width: 2, height: 2);
  img.fill(image, color: img.ColorRgb8(255, 255, 255));
  file.writeAsBytesSync(img.encodeJpg(image));
  return file;
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

class _FakePhotoPreviewProvider extends PhotoPreviewProvider {
  _FakePhotoPreviewProvider({bool isSaving = false})
    : _isSaving = isSaving,
      super(_FakePhotoRepository());

  final List<String> savedPaths = [];
  final List<String> retakenPaths = [];
  bool _isSaving;

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

  @override
  String get successMessage => 'Saved test photo';
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
