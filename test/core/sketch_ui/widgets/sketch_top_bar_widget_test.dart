import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';

import '../../../helpers/widget_test_app.dart';

void main() {
  testWidgets('shows its title and invokes the back action', (tester) async {
    var backCalls = 0;

    await tester.pumpWidget(
      buildTestApp(
        SketchTopBar(
          title: 'Settings',
          onBack: () {
            backCalls += 1;
          },
        ),
      ),
    );

    expect(find.text('Settings'), findsOneWidget);
    expect(find.byType(SketchIcon), findsOneWidget);

    await tester.tap(find.byType(SketchIcon));
    await tester.pump();

    expect(backCalls, 1);
  });
}
