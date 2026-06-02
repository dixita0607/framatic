import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';
import 'package:framatic/features/frames_manager/data/frame_repository.dart';
import 'package:framatic/features/frames_manager/presentation/frame_provider.dart';
import 'package:framatic/features/frames_manager/presentation/frames_manager_screen.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/frame_list_item.dart';
import 'package:provider/provider.dart';

import '../../../helpers/widget_test_app.dart';

void main() {
  group('FramesManagerScreen', () {
    testWidgets('shows progress while frames are loading', (tester) async {
      final provider = _LoadingFrameProvider();
      addTearDown(provider.dispose);

      await tester.pumpWidget(_screen(provider));
      await tester.pump();

      expect(find.text('Manage Frames'), findsOneWidget);
      expect(find.byType(SketchProgress), findsOneWidget);
      expect(find.byType(FrameListItem), findsNothing);
    });

    testWidgets('renders an empty list with the add action', (tester) async {
      final provider = FrameProvider(_FakeFrameRepository(frames: []));
      addTearDown(provider.dispose);

      await tester.pumpWidget(_screen(provider));
      await _settleProvider(tester);

      expect(find.text('Manage Frames'), findsOneWidget);
      expect(find.byType(FrameListItem), findsNothing);
      expect(find.bySemanticsLabel('Add Custom Frame'), findsOneWidget);
    });

    testWidgets('renders frames and persists reorder requests', (tester) async {
      final repository = _FakeFrameRepository(
        frames: [
          _frame(id: 1, title: '4:3', width: 4, height: 3),
          _frame(id: 2, title: '16:9', width: 16, height: 9),
          _frame(
            id: 3,
            title: 'Panorama',
            width: 21,
            height: 9,
            isCustom: true,
          ),
        ],
        order: ['1', '2', '3'],
      );
      final provider = FrameProvider(repository);
      addTearDown(provider.dispose);

      await tester.pumpWidget(_screen(provider));
      await _settleProvider(tester);

      expect(find.byType(FrameListItem), findsNWidgets(3));
      expect(find.text('Drag to set camera quick-access order.'), findsNothing);
      expect(find.text('Panorama'), findsOneWidget);
      expect(find.text('21:9'), findsOneWidget);
      expect(find.bySemanticsLabel('Edit Frame'), findsOneWidget);
      expect(find.bySemanticsLabel('Delete Frame'), findsOneWidget);
      expect(find.bySemanticsLabel('Reorder Panorama'), findsOneWidget);

      tester
          .widget<ReorderableList>(find.byType(ReorderableList))
          .onReorderItem!
          .call(0, 2);
      await _settleProvider(tester);

      expect(provider.frames.map((frame) => frame.id), [2, 3, 1]);
      expect(repository.setOrderCalls.last, ['2', '3', '1']);
    });

    testWidgets('adds a custom frame from the add dialog', (tester) async {
      final repository = _FakeFrameRepository(
        frames: [_frame(id: 1, title: '4:3', width: 4, height: 3)],
        order: ['1'],
      );
      final provider = FrameProvider(repository);
      addTearDown(provider.dispose);

      await tester.pumpWidget(_screen(provider));
      await _settleProvider(tester);

      await tester.tap(find.bySemanticsLabel('Add Custom Frame'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText).at(0), '  Cinema  ');
      await tester.enterText(find.byType(EditableText).at(1), '21');
      await tester.enterText(find.byType(EditableText).at(2), '9');
      await tester.tap(find.text('Save'));
      await _settleProviderAndAnimations(tester);

      expect(repository.createdFrames.single.title, 'Cinema');
      expect(find.text('Cinema'), findsOneWidget);
      expect(find.text('21:9'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('edits a custom frame from its row action', (tester) async {
      final repository = _FakeFrameRepository(
        frames: [
          _frame(id: 9, title: 'Custom', width: 2, height: 1, isCustom: true),
        ],
        order: ['9'],
      );
      final provider = FrameProvider(repository);
      addTearDown(provider.dispose);

      await tester.pumpWidget(_screen(provider));
      await _settleProvider(tester);

      await tester.tap(find.bySemanticsLabel('Edit Frame'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText).at(0), 'Story Frame');
      await tester.enterText(find.byType(EditableText).at(1), '4');
      await tester.enterText(find.byType(EditableText).at(2), '5');
      await tester.tap(find.text('Save'));
      await _settleProviderAndAnimations(tester);

      expect(repository.updatedFrames.single.id, 9);
      expect(repository.updatedFrames.single.title, 'Story Frame');
      expect(find.text('Story Frame'), findsOneWidget);
      expect(find.text('4:5'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('deletes a custom frame after confirmation', (tester) async {
      final repository = _FakeFrameRepository(
        frames: [
          _frame(id: 1, title: '4:3', width: 4, height: 3),
          _frame(
            id: 4,
            title: 'Disposable',
            width: 3,
            height: 2,
            isCustom: true,
          ),
        ],
        order: ['1', '4'],
      );
      final provider = FrameProvider(repository);
      addTearDown(provider.dispose);

      await tester.pumpWidget(_screen(provider));
      await _settleProvider(tester);

      await tester.tap(find.bySemanticsLabel('Delete Frame'));
      await tester.pumpAndSettle();

      expect(
        find.text('Are you sure you want to delete "Disposable"?'),
        findsOneWidget,
      );

      await tester.tap(find.text('Delete'));
      await _settleProviderAndAnimations(tester);

      expect(repository.deletedIds, [4]);
      expect(find.text('Disposable'), findsNothing);
      expect(find.text('4:3'), findsNWidgets(2));

      await tester.pump(const Duration(seconds: 3));
    });
  });
}

Widget _screen(FrameProvider provider) {
  return sketchTestApp(
    ChangeNotifierProvider<FrameProvider>.value(
      value: provider,
      child: const FramesManagerScreen(),
    ),
  );
}

Frame _frame({
  required int id,
  required String title,
  required int width,
  required int height,
  bool isCustom = false,
}) {
  return Frame(
    id: id,
    title: title,
    width: width,
    height: height,
    isCustom: isCustom,
  );
}

Future<void> _settleProvider(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump();
  }
}

Future<void> _settleProviderAndAnimations(WidgetTester tester) async {
  await _settleProvider(tester);
  await tester.pump(const Duration(milliseconds: 200));
}

class _FakeFrameRepository implements FrameRepository {
  _FakeFrameRepository({
    required List<Frame> frames,
    List<String> order = const [],
  }) : _frames = List.of(frames),
       _order = List.of(order);

  final List<Frame> _frames;
  final List<Frame> createdFrames = [];
  final List<Frame> updatedFrames = [];
  final List<int> deletedIds = [];
  final List<List<String>> setOrderCalls = [];

  var _order = <String>[];
  var _nextId = 100;

  @override
  Future<List<Frame>> getAllFrames() async => List.of(_frames);

  @override
  Future<List<String>> getOrder() async => List.of(_order);

  @override
  Future<void> setOrder(List<String> order) async {
    _order = List.of(order);
    setOrderCalls.add(List.of(order));
  }

  @override
  Future<Frame> createFrame(Frame frame) async {
    final createdFrame = frame.copyWith(id: frame.id ?? _nextId++);
    createdFrames.add(createdFrame);
    _frames.add(createdFrame);
    return createdFrame;
  }

  @override
  Future<Frame> updateFrame(Frame frame) async {
    updatedFrames.add(frame);
    final index = _frames.indexWhere((existing) => existing.id == frame.id);
    if (index != -1) {
      _frames[index] = frame;
    }
    return frame;
  }

  @override
  Future<int> deleteFrame(int id) async {
    deletedIds.add(id);
    _frames.removeWhere((frame) => frame.id == id);
    return id;
  }
}

class _LoadingFrameProvider extends FrameProvider {
  _LoadingFrameProvider() : super(_FakeFrameRepository(frames: []));

  @override
  bool get isLoading => true;

  @override
  List<Frame> get frames => const [];
}
