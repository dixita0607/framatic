import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';

import '../../../helpers/widget_test_app.dart';

void main() {
  testWidgets('exposes its tooltip and invokes its callback', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      buildTestApp(
        SketchIconButton(
          icon: SketchIconType.add,
          tooltip: 'Add frame',
          onPressed: () {
            taps += 1;
          },
        ),
      ),
    );

    final button = find.bySemanticsLabel('Add frame');
    expect(button, findsOneWidget);

    await tester.tap(button);
    await tester.pump();

    expect(taps, 1);
  });
}
