import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';

import '../../../helpers/widget_test_app.dart';

void main() {
  testWidgets('shows and removes an overlay message', (tester) async {
    await tester.pumpWidget(buildTestApp(const _ToastLauncher()));

    await tester.tap(find.text('Show toast'));
    await tester.pump();

    expect(find.text('Frame saved'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('Frame saved'), findsNothing);
  });
}

class _ToastLauncher extends StatelessWidget {
  const _ToastLauncher();

  @override
  Widget build(BuildContext context) {
    return SketchButton(
      label: 'Show toast',
      onPressed: () => SketchToast.show(
        context,
        'Frame saved',
        duration: const Duration(milliseconds: 100),
      ),
    );
  }
}
