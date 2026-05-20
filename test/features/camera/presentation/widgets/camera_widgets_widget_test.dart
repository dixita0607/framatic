import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';
import 'package:framatic/features/camera/presentation/widgets/camera_error_widget.dart';
import 'package:framatic/features/camera/presentation/widgets/capture_button.dart';
import 'package:framatic/features/camera/presentation/widgets/frame_selector.dart';

void main() {
  group('FrameSelector', () {
    testWidgets('shows a progress indicator while loading', (tester) async {
      final frames = _frames();

      await tester.pumpWidget(
        _testApp(
          FrameSelector(
            frames: frames,
            activeFrame: frames.first,
            isLoading: true,
            onFrameSelected: (_) {},
          ),
        ),
      );

      expect(find.byType(SketchProgress), findsOneWidget);
      expect(find.text('4:3'), findsNothing);
    });

    testWidgets('selects a frame by id when its chip is tapped', (
      tester,
    ) async {
      final frames = _frames();
      int? selectedFrameId;

      await tester.pumpWidget(
        _testApp(
          FrameSelector(
            frames: frames,
            activeFrame: frames.first,
            isLoading: false,
            onFrameSelected: (frameId) {
              selectedFrameId = frameId;
            },
          ),
        ),
      );

      await tester.tap(find.text('Square'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(selectedFrameId, 3);
    });

    testWidgets('does not overflow on a narrow viewport smoke test', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final frames = _frames()
        ..addAll([
          Frame(id: 4, title: 'Panorama', width: 21, height: 9),
          Frame(id: 5, title: 'Portrait', width: 9, height: 16),
        ]);

      await tester.pumpWidget(
        _testApp(
          FrameSelector(
            frames: frames,
            activeFrame: frames.first,
            isLoading: false,
            onFrameSelected: (_) {},
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('4:3'), findsOneWidget);
    });
  });

  group('CameraErrorWidget', () {
    testWidgets('shows fallback message and retries', (tester) async {
      var retryCount = 0;

      await tester.pumpWidget(
        _testApp(
          CameraErrorWidget(
            error: null,
            onRetry: () {
              retryCount += 1;
            },
          ),
        ),
      );

      expect(find.text('An error occurred'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retryCount, 1);
    });

    testWidgets('shows permission guidance without opening settings', (
      tester,
    ) async {
      await tester.pumpWidget(
        _testApp(
          CameraErrorWidget(
            error: const PermissionError(
              'Camera denied',
              userMessage: 'Camera permission is needed.',
            ),
            onRetry: () {},
          ),
        ),
      );

      expect(find.text('Camera permission is needed.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Open Settings'), findsOneWidget);
    });
  });

  group('CaptureButton', () {
    testWidgets('invokes the callback on tap', (tester) async {
      var captures = 0;

      await tester.pumpWidget(
        _testApp(
          CaptureButton(
            onPressed: () {
              captures += 1;
            },
          ),
        ),
      );

      await tester.tap(find.byType(CaptureButton));
      await tester.pumpAndSettle();

      expect(captures, 1);
    });

    testWidgets('shows progress while capture is in flight', (tester) async {
      await tester.pumpWidget(
        _testApp(const CaptureButton(onPressed: null, isCapturing: true)),
      );

      expect(find.byType(SketchProgress), findsOneWidget);
    });
  });
}

List<Frame> _frames() {
  return [
    Frame(id: 1, title: '4:3', width: 4, height: 3),
    Frame(id: 2, title: '16:9', width: 16, height: 9),
    Frame(id: 3, title: 'Square', width: 1, height: 1),
  ];
}

Widget _testApp(Widget child) {
  const theme = SketchThemeCatalog.monochromeLight;
  return SketchTheme(
    data: theme,
    child: WidgetsApp(
      color: theme.background,
      textStyle: theme.bodyStyle,
      pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
      ),
      home: DefaultTextStyle(style: theme.bodyStyle, child: child),
    ),
  );
}
