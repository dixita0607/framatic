import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';

import '../../../helpers/widget_test_app.dart';

void main() {
  testWidgets('shows its label and updates its controller', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      buildTestApp(
        Form(
          child: SketchFormInput(
            controller: controller,
            label: 'Frame name',
            hint: 'e.g. Panorama',
          ),
        ),
      ),
    );

    expect(find.text('Frame name'), findsOneWidget);
    expect(find.text('e.g. Panorama'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'Panorama');
    await tester.pump();

    expect(controller.text, 'Panorama');
  });
}
