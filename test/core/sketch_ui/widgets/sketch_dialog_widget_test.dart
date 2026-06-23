import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';

import '../../../helpers/widget_test_app.dart';

void main() {
  testWidgets('opens as a popup route and renders its content', (tester) async {
    await tester.pumpWidget(buildTestApp(const _DialogLauncher()));

    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm action'), findsOneWidget);
    expect(find.text('Dialog content'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm action'), findsNothing);
  });
}

class _DialogLauncher extends StatelessWidget {
  const _DialogLauncher();

  @override
  Widget build(BuildContext context) {
    return SketchButton(
      label: 'Open dialog',
      onPressed: () => showSketchDialog<void>(
        context: context,
        builder: (context) => SketchDialog(
          title: 'Confirm action',
          actions: [
            SketchButton(
              label: 'Close',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          child: const Text('Dialog content'),
        ),
      ),
    );
  }
}
