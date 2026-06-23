import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';

import '../../../helpers/widget_test_app.dart';

void main() {
  testWidgets('shows a label and taps once', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      buildTestApp(
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
}
