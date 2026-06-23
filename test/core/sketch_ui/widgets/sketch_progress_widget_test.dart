import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';

import '../../../helpers/widget_test_app.dart';

void main() {
  testWidgets('renders an animated custom-painted progress mark', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(const Center(child: SketchProgress(size: 32))),
    );

    expect(find.byType(SketchProgress), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(SketchProgress),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });
}
