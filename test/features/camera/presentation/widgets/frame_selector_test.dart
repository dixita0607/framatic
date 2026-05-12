import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/features/camera/presentation/widgets/frame_selector.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

final _frame1 = Frame(id: 1, title: "16:9", width: 16, height: 9);
final _frame2 = Frame(id: 2, title: "4:3", width: 4, height: 3);
final _frame3 = Frame(id: 3, title: "1:1", width: 1, height: 1);

Widget buildTestApp(Widget child) {
  return SketchyApp(title: 'Test', home: child);
}

void main() {
  group('FrameSelector', () {
    testWidgets('shows SketchyCircularProgressIndicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(buildTestApp(
        FrameSelector(
          frames: [_frame1],
          activeFrame: _frame1,
          isLoading: true,
          onFrameSelected: (_) {},
        ),
      ));

      expect(find.byType(SketchyCircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders a chip for each frame', (tester) async {
      await tester.pumpWidget(buildTestApp(
        FrameSelector(
          frames: [_frame1, _frame2, _frame3],
          activeFrame: _frame1,
          isLoading: false,
          onFrameSelected: (_) {},
        ),
      ));

      expect(find.byType(SketchyChoiceChip), findsNWidgets(3));
    });

    testWidgets('renders frame titles', (tester) async {
      await tester.pumpWidget(buildTestApp(
        FrameSelector(
          frames: [_frame1, _frame2],
          activeFrame: _frame1,
          isLoading: false,
          onFrameSelected: (_) {},
        ),
      ));

      expect(find.text('16:9'), findsOneWidget);
      expect(find.text('4:3'), findsOneWidget);
    });

    testWidgets('active frame chip is selected', (tester) async {
      await tester.pumpWidget(buildTestApp(
        FrameSelector(
          frames: [_frame1, _frame2],
          activeFrame: _frame2,
          isLoading: false,
          onFrameSelected: (_) {},
        ),
      ));

      final chips =
          tester.widgetList<SketchyChoiceChip>(find.byType(SketchyChoiceChip)).toList();
      expect(chips[0].selected, isFalse);
      expect(chips[1].selected, isTrue);
    });

    testWidgets('tapping a chip calls onFrameSelected with correct id',
        (tester) async {
      int? selectedId;

      await tester.pumpWidget(buildTestApp(
        FrameSelector(
          frames: [_frame1, _frame2],
          activeFrame: _frame1,
          isLoading: false,
          onFrameSelected: (id) => selectedId = id,
        ),
      ));

      await tester.tap(find.text('4:3'));
      await tester.pump();

      expect(selectedId, equals(2));
    });

    testWidgets('renders empty list without error', (tester) async {
      await tester.pumpWidget(buildTestApp(
        FrameSelector(
          frames: const [],
          activeFrame: _frame1,
          isLoading: false,
          onFrameSelected: (_) {},
        ),
      ));

      expect(find.byType(SketchyChoiceChip), findsNothing);
    });
  });
}
