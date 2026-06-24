import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/widgets/paper_frame.dart';

void main() {
  testWidgets('renders the soft paper finish and exposes its ratio', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: PaperFrame(
            imageWidth: 160,
            imageHeight: 90,
            borderWidth: 8,
            bottomBorderWidth: 12.4,
            ratioLabel: '16 x 9',
            child: ColoredBox(color: Color(0xFF496A72)),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Paper cutout frame, 16 x 9'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('paper-frame-background')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('paper-frame-finish')), findsOneWidget);
    expect(find.text('16 x 9'), findsOneWidget);
    expect(tester.getSize(find.byType(PaperFrame)), const Size(176, 110.4));
  });
}
