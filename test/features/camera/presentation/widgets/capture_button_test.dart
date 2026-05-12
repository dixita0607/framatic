import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/features/camera/presentation/widgets/capture_button.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

Widget buildTestApp(Widget child) {
  return SketchyApp(title: 'Test', home: child);
}

void main() {
  group('CaptureButton', () {
    testWidgets('renders without loading indicator in normal state',
        (tester) async {
      await tester.pumpWidget(buildTestApp(
        CaptureButton(
          isCapturing: false,
          onPressed: () {},
        ),
      ));

      expect(find.byType(SketchyCircularProgressIndicator), findsNothing);
    });

    testWidgets('shows SketchyCircularProgressIndicator when isCapturing is true',
        (tester) async {
      await tester.pumpWidget(buildTestApp(
        CaptureButton(
          isCapturing: true,
          onPressed: () {},
        ),
      ));

      expect(find.byType(SketchyCircularProgressIndicator), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(buildTestApp(
        CaptureButton(
          isCapturing: false,
          onPressed: () => tapped = true,
        ),
      ));

      await tester.tapAt(tester.getCenter(find.byType(GestureDetector).first));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('renders with null onPressed without errors', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const CaptureButton(
          isCapturing: false,
          onPressed: null,
        ),
      ));

      expect(find.byType(CaptureButton), findsOneWidget);
    });

    testWidgets('renders SketchyFrame circle', (tester) async {
      await tester.pumpWidget(buildTestApp(
        CaptureButton(
          isCapturing: false,
          onPressed: () {},
        ),
      ));

      expect(find.byType(SketchyFrame), findsOneWidget);
    });
  });
}
