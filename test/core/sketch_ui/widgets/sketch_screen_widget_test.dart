import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';

import '../../../helpers/widget_test_app.dart';

void main() {
  testWidgets('smoke renders at phone-sized constraints', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildTestApp(
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
}
