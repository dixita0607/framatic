import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/delete_frame_dialog.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/frame_list_item.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/manage_frame_dialog.dart';

void main() {
  group('ManageFrameDialog', () {
    testWidgets('validates required fields before saving', (tester) async {
      await tester.pumpWidget(
        _testApp(
          _DialogLauncher(
            builder: (_) => ManageFrameDialog(onSave: (_) async {}),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Frame name is required'), findsOneWidget);
      expect(find.text('Enter width'), findsOneWidget);
      expect(find.text('Enter height'), findsOneWidget);
    });

    testWidgets('saves a trimmed custom frame from form input', (tester) async {
      Frame? savedFrame;

      await tester.pumpWidget(
        _testApp(
          _DialogLauncher(
            builder: (_) => ManageFrameDialog(
              onSave: (frame) async {
                savedFrame = frame;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText).at(0), '  Panorama  ');
      await tester.enterText(find.byType(EditableText).at(1), '21');
      await tester.enterText(find.byType(EditableText).at(2), '9');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedFrame, isNotNull);
      expect(savedFrame!.id, isNull);
      expect(savedFrame!.title, 'Panorama');
      expect(savedFrame!.width, 21);
      expect(savedFrame!.height, 9);
      expect(savedFrame!.isCustom, isTrue);
      expect(find.text('Add Frame'), findsNothing);

      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('pre-fills fields when editing a custom frame', (tester) async {
      final frame = Frame(
        id: 7,
        title: 'Story',
        width: 4,
        height: 5,
        isCustom: true,
      );

      await tester.pumpWidget(
        _testApp(
          _DialogLauncher(
            builder: (_) =>
                ManageFrameDialog(frame: frame, onSave: (_) async {}),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Frame'), findsOneWidget);
      expect(_editableTextAt(tester, 0), 'Story');
      expect(_editableTextAt(tester, 1), '4');
      expect(_editableTextAt(tester, 2), '5');
    });

    testWidgets('shows entered ratio preview while typing', (tester) async {
      await tester.pumpWidget(
        _testApp(
          _DialogLauncher(
            builder: (_) => ManageFrameDialog(onSave: (_) async {}),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Preview'), findsOneWidget);

      await tester.enterText(find.byType(EditableText).at(1), '8');
      await tester.enterText(find.byType(EditableText).at(2), '16');
      await tester.pump();

      expect(find.text('Preview 8:16'), findsOneWidget);
    });

    testWidgets('warns about duplicate names and ratios', (tester) async {
      await tester.pumpWidget(
        _testApp(
          _DialogLauncher(
            builder: (_) => ManageFrameDialog(
              existingFrames: [
                Frame(id: 1, title: 'Cinema', width: 21, height: 9),
              ],
              onSave: (_) async {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText).at(0), 'cinema');
      await tester.enterText(find.byType(EditableText).at(1), '7');
      await tester.enterText(find.byType(EditableText).at(2), '3');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Frame name already exists'), findsOneWidget);
      expect(find.text('Ratio already exists'), findsOneWidget);
    });
  });

  group('DeleteFrameDialog', () {
    testWidgets('confirms the frame title and deletes by id', (tester) async {
      int? deletedId;
      final frame = Frame(
        id: 42,
        title: 'Custom Square',
        width: 1,
        height: 1,
        isCustom: true,
      );

      await tester.pumpWidget(
        _testApp(
          _DialogLauncher(
            builder: (_) => DeleteFrameDialog(
              frame: frame,
              onDelete: (frameId) async {
                deletedId = frameId;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(
        find.text('Are you sure you want to delete "Custom Square"?'),
        findsOneWidget,
      );

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(deletedId, 42);
      expect(find.text('Delete Frame'), findsNothing);

      await tester.pump(const Duration(seconds: 3));
    });
  });

  group('FrameListItem', () {
    testWidgets('hides edit and delete actions for predefined frames', (
      tester,
    ) async {
      await tester.pumpWidget(
        _testApp(
          FrameListItem(
            frame: Frame(id: 1, title: '16:9', width: 16, height: 9),
            order: 0,
            onEdit: (_) async {},
            onDelete: (_) async {},
          ),
        ),
      );

      expect(find.text('16:9'), findsNWidgets(2));
      expect(find.bySemanticsLabel('Edit Frame'), findsNothing);
      expect(find.bySemanticsLabel('Delete Frame'), findsNothing);
    });

    testWidgets('exposes edit and delete actions for custom frames', (
      tester,
    ) async {
      await tester.pumpWidget(
        _testApp(
          FrameListItem(
            frame: Frame(
              id: 2,
              title: 'Panorama',
              width: 21,
              height: 9,
              isCustom: true,
            ),
            order: 0,
            onEdit: (_) async {},
            onDelete: (_) async {},
          ),
        ),
      );

      expect(find.text('Panorama'), findsOneWidget);
      expect(find.text('21:9'), findsOneWidget);
      expect(find.bySemanticsLabel('Edit Frame'), findsOneWidget);
      expect(find.bySemanticsLabel('Delete Frame'), findsOneWidget);
      expect(find.bySemanticsLabel('Reorder Panorama'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Edit Frame'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Frame'), findsOneWidget);
      expect(_editableTextAt(tester, 0), 'Panorama');
    });
  });
}

String _editableTextAt(WidgetTester tester, int index) {
  return tester
      .widget<EditableText>(find.byType(EditableText).at(index))
      .controller
      .text;
}

Widget _testApp(Widget child) {
  const theme = SketchThemeCatalog.graphiteLight;
  return SketchTheme(
    data: theme,
    child: WidgetsApp(
      color: theme.background,
      textStyle: theme.bodyStyle,
      pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
      ),
      home: DefaultTextStyle(style: theme.bodyStyle, child: child),
    ),
  );
}

class _DialogLauncher extends StatelessWidget {
  final WidgetBuilder builder;

  const _DialogLauncher({required this.builder});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SketchButton(
        label: 'Open',
        onPressed: () => showSketchDialog(context: context, builder: builder),
      ),
    );
  }
}
