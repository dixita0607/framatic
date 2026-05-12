import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/features/frames_manager/presentation/frame_provider.dart';
import 'package:framatic/features/frames_manager/presentation/frames_manager_screen.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/manage_frame_dialog.dart';
import 'package:provider/provider.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

// ---- Fake FrameProvider ----

class FakeFrameProvider extends ChangeNotifier implements FrameProvider {
  @override List<Frame> frames;
  @override bool isLoading;
  int? _activeFrameId;

  FakeFrameProvider({
    List<Frame>? frames,
    this.isLoading = false,
  }) : frames = frames ?? [];

  @override
  Frame? get activeFrame => _activeFrameId == null
      ? null
      : frames.where((f) => f.id == _activeFrameId).firstOrNull;

  @override
  void setActiveFrame(int frameId) {
    _activeFrameId = frameId;
    notifyListeners();
  }

  @override
  Future<Frame> createFrame(Frame newFrame) async {
    final created = newFrame.copyWith(id: frames.length + 1);
    frames.insert(0, created);
    notifyListeners();
    return created;
  }

  @override
  Future<Frame> updateFrame(Frame frame) async {
    final idx = frames.indexWhere((f) => f.id == frame.id);
    if (idx != -1) frames[idx] = frame;
    notifyListeners();
    return frame;
  }

  @override
  Future<void> deleteFrame(int frameId) async {
    frames.removeWhere((f) => f.id == frameId);
    notifyListeners();
  }

  @override
  Future<void> orderFrames(int oldPos, int newPos) async {
    final item = frames.removeAt(oldPos);
    var idx = newPos;
    if (oldPos < newPos) idx -= 1;
    frames.insert(idx, item);
    notifyListeners();
  }
}

Widget buildTestApp({FakeFrameProvider? frameProvider}) {
  return SketchyApp(
    title: 'Test',
    home: ChangeNotifierProvider<FrameProvider>.value(
      value: frameProvider ?? FakeFrameProvider(),
      child: const FramesManagerScreen(),
    ),
  );
}

void main() {
  group('FramesManagerScreen', () {
    testWidgets('shows SketchyCircularProgressIndicator when isLoading is true',
        (tester) async {
      final provider = FakeFrameProvider(isLoading: true);

      await tester.pumpWidget(buildTestApp(frameProvider: provider));
      await tester.pump();

      expect(find.byType(SketchyCircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders FrameListItem for each frame when not loading',
        (tester) async {
      final frames = [
        Frame(id: 1, title: "Widescreen", width: 16, height: 9),
        Frame(id: 2, title: "Standard", width: 4, height: 3),
      ];
      final provider = FakeFrameProvider(frames: frames);

      await tester.pumpWidget(buildTestApp(frameProvider: provider));
      await tester.pump();

      expect(find.text('Widescreen'), findsOneWidget);
      expect(find.text('Standard'), findsOneWidget);
    });

    testWidgets('FrameListItem shows title and ratio', (tester) async {
      final frames = [
        Frame(id: 1, title: "Widescreen", width: 16, height: 9),
      ];
      final provider = FakeFrameProvider(frames: frames);

      await tester.pumpWidget(buildTestApp(frameProvider: provider));
      await tester.pump();

      expect(find.text('Widescreen'), findsOneWidget);
      expect(find.text('16:9'), findsOneWidget);
    });

    testWidgets('FAB is present', (tester) async {
      final provider = FakeFrameProvider(frames: []);

      await tester.pumpWidget(buildTestApp(frameProvider: provider));
      await tester.pump();

      expect(find.byKey(const Key('add_frame_fab')), findsOneWidget);
    });

    testWidgets('tapping FAB opens ManageFrameDialog', (tester) async {
      final provider = FakeFrameProvider(frames: []);

      await tester.pumpWidget(buildTestApp(frameProvider: provider));
      await tester.pump();

      await tester.tap(find.byKey(const Key('add_frame_fab')));
      await tester.pumpAndSettle();

      expect(find.byType(ManageFrameDialog), findsOneWidget);
    });

    testWidgets('shows empty list without errors when no frames', (tester) async {
      final provider = FakeFrameProvider(frames: []);

      await tester.pumpWidget(buildTestApp(frameProvider: provider));
      await tester.pump();

      expect(find.byKey(const Key('add_frame_fab')), findsOneWidget);
    });
  });
}
