import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';
import 'package:framatic/features/frames_manager/data/frame_repository.dart';
import 'package:framatic/features/frames_manager/presentation/frame_provider.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/delete_frame_dialog.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/frame_list_item.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/manage_frame_dialog.dart';
import 'package:provider/provider.dart';

void main() {
  group('ManageFrameDialog', () {
    testWidgets('stays scrollable above the keyboard on a short viewport', (
      tester,
    ) async {
      addTearDown(tester.view.reset);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 500);

      await tester.pumpWidget(
        _testApp(
          _DialogLauncher(
            builder: (_) => ManageFrameDialog(onSave: (_) async {}),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.showKeyboard(find.byType(EditableText).last);
      tester.view.viewInsets = const FakeViewPadding(bottom: 220);
      await tester.pumpAndSettle();

      final scrollable = find.descendant(
        of: find.byType(SketchDialog),
        matching: find.byType(SingleChildScrollView),
      );
      expect(scrollable, findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Save').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

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

    testWidgets('warns about a duplicate name when the ratio is unique', (
      tester,
    ) async {
      await tester.pumpWidget(
        _testApp(
          _DialogLauncher(
            builder: (_) => ManageFrameDialog(onSave: (_) async {}),
          ),
          frames: [Frame(id: 1, title: 'Cinema', width: 21, height: 9)],
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText).at(0), 'cinema');
      await tester.enterText(find.byType(EditableText).at(1), '32');
      await tester.enterText(find.byType(EditableText).at(2), '9');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Frame name already exists'), findsOneWidget);
      expect(find.text('Ratio already exists'), findsNothing);
    });

    testWidgets('warns about a duplicate ratio when the name is unique', (
      tester,
    ) async {
      await tester.pumpWidget(
        _testApp(
          _DialogLauncher(
            builder: (_) => ManageFrameDialog(onSave: (_) async {}),
          ),
          frames: [Frame(id: 1, title: 'Cinema', width: 21, height: 9)],
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText).at(0), 'Vista');
      await tester.enterText(find.byType(EditableText).at(1), '21');
      await tester.enterText(find.byType(EditableText).at(2), '9');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Frame name already exists'), findsNothing);
      expect(find.text('Ratio already exists'), findsOneWidget);
    });

    testWidgets('allows proportionally equivalent dimensions', (tester) async {
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
          frames: [Frame(id: 1, title: 'Classic', width: 4, height: 3)],
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText).at(0), 'Large Classic');
      await tester.enterText(find.byType(EditableText).at(1), '8');
      await tester.enterText(find.byType(EditableText).at(2), '6');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedFrame?.width, 8);
      expect(savedFrame?.height, 6);

      await tester.pump(const Duration(seconds: 3));
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

Widget _testApp(Widget child, {List<Frame> frames = const []}) {
  const theme = SketchThemeCatalog.graphiteLight;
  return ChangeNotifierProvider<FrameProvider>(
    create: (_) => _TestFrameProvider(frames),
    child: SketchTheme(
      data: theme,
      child: WidgetsApp(
        color: theme.background,
        textStyle: theme.bodyText,
        pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
        ),
        home: DefaultTextStyle(style: theme.bodyText, child: child),
      ),
    ),
  );
}

class _TestFrameProvider extends FrameProvider {
  final List<Frame> _testFrames;

  _TestFrameProvider(this._testFrames)
    : super(_TestFrameRepository(_testFrames));

  @override
  List<Frame> get frames => _testFrames;
}

class _TestFrameRepository implements FrameRepository {
  final List<Frame> frames;

  _TestFrameRepository(this.frames);

  @override
  Future<List<Frame>> getAllFrames() async => frames;

  @override
  Future<List<String>> getOrder() async =>
      frames.map((frame) => frame.id.toString()).toList();

  @override
  Future<void> setOrder(List<String> order) async {}

  @override
  Future<Frame> createFrame(Frame frame) async => frame;

  @override
  Future<Frame> updateFrame(Frame frame) async => frame;

  @override
  Future<int> deleteFrame(int id) async => id;
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
