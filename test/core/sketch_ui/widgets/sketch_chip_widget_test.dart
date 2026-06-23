import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';

import '../../../helpers/widget_test_app.dart';

void main() {
  testWidgets('reports selection and invokes its callback', (tester) async {
    var selections = 0;

    await tester.pumpWidget(
      buildTestApp(
        SketchChip(
          label: '4:3',
          semanticLabel: 'Select 4 by 3 frame',
          selected: true,
          onSelected: () {
            selections += 1;
          },
        ),
      ),
    );

    final chip = find.text('4:3');
    expect(chip, findsOneWidget);

    await tester.tap(chip);
    await tester.pump();

    expect(selections, 1);
  });
}
