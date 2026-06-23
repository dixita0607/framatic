import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';

import '../../../helpers/widget_test_app.dart';

void main() {
  testWidgets('reports clamped drag values', (tester) async {
    final values = <double>[];

    await tester.pumpWidget(
      buildTestApp(
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
}
