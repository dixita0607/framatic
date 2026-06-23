import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';
import 'package:framatic/core/widgets/circular_action_button.dart';

import '../../helpers/widget_test_app.dart';

void main() {
  testWidgets('invokes callback when enabled', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      buildTestApp(
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
      buildTestApp(
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
}
