import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';
import 'package:framatic/core/widgets/circular_action_button.dart';

void main() {
  group('SketchButton', () {
    testWidgets('shows a label and taps once', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        _testApp(
          Center(
            child: SketchButton(
              label: 'Apply',
              onPressed: () {
                taps += 1;
              },
            ),
          ),
        ),
      );

      expect(find.text('Apply'), findsOneWidget);

      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(taps, 1);
    });
  });

  group('SketchSlider', () {
    testWidgets('reports clamped drag values', (tester) async {
      final values = <double>[];

      await tester.pumpWidget(
        _testApp(
          Center(
            child: SizedBox(
              width: 200,
              child: SketchSlider(value: 0.5, onChanged: values.add),
            ),
          ),
        ),
      );

      await tester.dragFrom(
        tester.getCenter(find.byType(SketchSlider)),
        const Offset(300, 0),
      );
      await tester.pump();

      expect(values, isNotEmpty);
      expect(values.last, 1);

      await tester.dragFrom(
        tester.getCenter(find.byType(SketchSlider)),
        const Offset(-300, 0),
      );
      await tester.pump();

      expect(values.last, 0);
    });
  });

  group('CircularActionButton', () {
    testWidgets('invokes callback when enabled', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        _testApp(
          Center(
            child: CircularActionButton(
              icon: SketchIconType.check,
              label: 'Save',
              onPressed: () {
                taps += 1;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SketchIcon));
      await tester.pump();

      expect(taps, 1);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('shows progress and ignores taps when loading', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        _testApp(
          Center(
            child: CircularActionButton(
              icon: SketchIconType.check,
              label: 'Save',
              isLoading: true,
              onPressed: () {
                taps += 1;
              },
            ),
          ),
        ),
      );

      expect(find.byType(SketchProgress), findsOneWidget);

      await tester.tap(find.byType(CircularActionButton));
      await tester.pump();

      expect(taps, 0);
    });
  });

  group('SketchScreen', () {
    testWidgets('smoke renders at phone-sized constraints', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _testApp(
          SketchScreen(
            title: 'Manage Frames',
            onBack: () {},
            floatingActionButton: SketchIconButton(
              icon: SketchIconType.add,
              onPressed: () {},
              tooltip: 'Add Custom Frame',
            ),
            child: const Center(child: Text('Content')),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Manage Frames'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
      expect(find.bySemanticsLabel('Add Custom Frame'), findsOneWidget);
    });
  });
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
