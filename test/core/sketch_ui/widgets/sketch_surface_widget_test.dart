import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';

import '../../../helpers/widget_test_app.dart';

void main() {
  testWidgets('renders its child with a sketch border painter', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        const Center(
          child: SketchSurface(
            padding: EdgeInsets.all(8),
            child: Text('Panel content'),
          ),
        ),
      ),
    );

    expect(find.text('Panel content'), findsOneWidget);
    final customPaint = find.descendant(
      of: find.byType(SketchSurface),
      matching: find.byType(CustomPaint),
    );
    expect(
      tester.widget<CustomPaint>(customPaint).painter,
      isA<SketchBorderPainter>(),
    );
  });
}
