import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/features/frames_manager/data/frame_repository.dart';
import 'package:framatic/features/frames_manager/domain/frame_error.dart';
import 'package:framatic/features/frames_manager/presentation/frame_provider.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class FakeFrameRepository implements FrameRepository {
  List<Frame> framesToReturn;
  List<String> orderToReturn;
  Exception? errorToThrow;

  final List<String> setCalls = [];
  int _nextId = 100;

  FakeFrameRepository({
    List<Frame>? frames,
    List<String>? order,
    this.errorToThrow,
  })  : framesToReturn = frames ?? [],
        orderToReturn = order ?? [];

  @override
  Future<List<Frame>> getAllFrames() async {
    if (errorToThrow != null) throw errorToThrow!;
    return List<Frame>.from(framesToReturn);
  }

  @override
  Future<List<String>> getOrder() async => List<String>.from(orderToReturn);

  @override
  Future<void> setOrder(List<String> order) async {
    setCalls.add(order.join(','));
  }

  @override
  Future<Frame> createFrame(Frame frame) async {
    if (errorToThrow != null) throw errorToThrow!;
    final created = frame.copyWith(id: _nextId++);
    framesToReturn.insert(0, created);
    return created;
  }

  @override
  Future<Frame> updateFrame(Frame frame) async {
    if (errorToThrow != null) throw errorToThrow!;
    final idx = framesToReturn.indexWhere((f) => f.id == frame.id);
    if (idx != -1) framesToReturn[idx] = frame;
    return frame;
  }

  @override
  Future<int> deleteFrame(int id) async {
    if (errorToThrow != null) throw errorToThrow!;
    framesToReturn.removeWhere((f) => f.id == id);
    return id;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Frame _frame(int id, String title) =>
    Frame(id: id, title: title, width: 16, height: 9, isCustom: true);

/// Wait for the async constructor (_initialize) to complete.
Future<void> _settle() => Future<void>.microtask(() {});

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('FrameProvider', () {
    group('initialization', () {
      test('populates frames and sets activeFrame to first frame', () async {
        final frames = [_frame(1, 'A'), _frame(2, 'B'), _frame(3, 'C')];
        final repo = FakeFrameRepository(
          frames: frames,
          order: ['1', '2', '3'],
        );
        final provider = FrameProvider(repo);

        await pumpEventQueue();

        expect(provider.frames.length, 3);
        expect(provider.activeFrame?.id, 1);
        expect(provider.isLoading, isFalse);
      });

      test('isLoading is false after initialization completes', () async {
        final repo = FakeFrameRepository(
          frames: [_frame(1, 'A')],
          order: ['1'],
        );
        final provider = FrameProvider(repo);

        await pumpEventQueue();

        expect(provider.isLoading, isFalse);
      });

      test('activeFrame is null when no frames exist', () async {
        final repo = FakeFrameRepository(frames: [], order: []);
        final provider = FrameProvider(repo);

        await pumpEventQueue();

        expect(provider.activeFrame, isNull);
        expect(provider.frames, isEmpty);
      });

      test('frames are sorted according to stored order', () async {
        final frames = [_frame(1, 'A'), _frame(2, 'B'), _frame(3, 'C')];
        final repo = FakeFrameRepository(
          frames: frames,
          order: ['3', '1', '2'],
        );
        final provider = FrameProvider(repo);

        await pumpEventQueue();

        expect(provider.frames.map((f) => f.id).toList(), [3, 1, 2]);
      });
    });

    group('createFrame', () {
      test('inserts created frame at index 0', () async {
        final repo = FakeFrameRepository(
          frames: [_frame(1, 'Existing')],
          order: ['1'],
        );
        final provider = FrameProvider(repo);
        await pumpEventQueue();

        final newFrame = Frame(title: 'New', width: 4, height: 3, isCustom: true);
        final created = await provider.createFrame(newFrame);

        expect(created.id, isNotNull);
        expect(provider.frames[0].id, created.id);
      });

      test('createFrame returns the created frame', () async {
        final repo = FakeFrameRepository(frames: [], order: []);
        final provider = FrameProvider(repo);
        await pumpEventQueue();

        final newFrame = Frame(title: 'New', width: 4, height: 3, isCustom: true);
        final created = await provider.createFrame(newFrame);

        expect(created.title, 'New');
        expect(created.id, isNotNull);
      });

      test('updates order after createFrame', () async {
        final repo = FakeFrameRepository(frames: [], order: []);
        final provider = FrameProvider(repo);
        await pumpEventQueue();
        repo.setCalls.clear();

        await provider.createFrame(
          Frame(title: 'New', width: 4, height: 3, isCustom: true),
        );

        expect(repo.setCalls, isNotEmpty);
      });

      test('isLoading is false after createFrame completes', () async {
        final repo = FakeFrameRepository(frames: [], order: []);
        final provider = FrameProvider(repo);
        await pumpEventQueue();

        await provider.createFrame(
          Frame(title: 'New', width: 4, height: 3, isCustom: true),
        );

        expect(provider.isLoading, isFalse);
      });

      test('rethrows when repo throws', () async {
        final repo = FakeFrameRepository(frames: [], order: []);
        final provider = FrameProvider(repo);
        await pumpEventQueue();

        repo.errorToThrow = Exception('db error');

        expect(
          () => provider.createFrame(
            Frame(title: 'New', width: 4, height: 3, isCustom: true),
          ),
          throwsException,
        );
      });

      test('isLoading resets to false when repo throws', () async {
        final repo = FakeFrameRepository(frames: [], order: []);
        final provider = FrameProvider(repo);
        await pumpEventQueue();

        repo.errorToThrow = Exception('db error');
        try {
          await provider.createFrame(
            Frame(title: 'New', width: 4, height: 3, isCustom: true),
          );
        } catch (_) {}

        expect(provider.isLoading, isFalse);
      });
    });

    group('updateFrame', () {
      test('replaces existing frame in list by id', () async {
        final frames = [_frame(1, 'Original'), _frame(2, 'B')];
        final repo = FakeFrameRepository(
          frames: frames,
          order: ['1', '2'],
        );
        final provider = FrameProvider(repo);
        await pumpEventQueue();

        final updated = _frame(1, 'Updated');
        await provider.updateFrame(updated);

        final found = provider.frames.firstWhere((f) => f.id == 1);
        expect(found.title, 'Updated');
      });

      test('isLoading is false after updateFrame completes', () async {
        final frames = [_frame(1, 'A')];
        final repo = FakeFrameRepository(frames: frames, order: ['1']);
        final provider = FrameProvider(repo);
        await pumpEventQueue();

        await provider.updateFrame(_frame(1, 'B'));

        expect(provider.isLoading, isFalse);
      });
    });

    group('deleteFrame', () {
      test('removes frame from list', () async {
        final frames = [_frame(1, 'A'), _frame(2, 'B')];
        final repo = FakeFrameRepository(
          frames: frames,
          order: ['1', '2'],
        );
        final provider = FrameProvider(repo);
        await pumpEventQueue();

        await provider.deleteFrame(2);

        expect(provider.frames.any((f) => f.id == 2), isFalse);
      });

      test('updates order after deleteFrame', () async {
        final frames = [_frame(1, 'A'), _frame(2, 'B')];
        final repo = FakeFrameRepository(
          frames: frames,
          order: ['1', '2'],
        );
        final provider = FrameProvider(repo);
        await pumpEventQueue();
        repo.setCalls.clear();

        await provider.deleteFrame(2);

        expect(repo.setCalls, isNotEmpty);
      });

      test('activeFrame shifts to frames[0] when active frame is deleted', () async {
        final frames = [_frame(1, 'A'), _frame(2, 'B'), _frame(3, 'C')];
        final repo = FakeFrameRepository(
          frames: frames,
          order: ['1', '2', '3'],
        );
        final provider = FrameProvider(repo);
        await pumpEventQueue();

        // Active frame starts as first frame (id=1). Delete it.
        await provider.deleteFrame(1);

        // Should now be frames[0] of remaining list.
        expect(provider.activeFrame, isNotNull);
        expect(provider.activeFrame!.id, isNot(1));
      });

      test('deleting non-active frame does not change activeFrame', () async {
        final frames = [_frame(1, 'A'), _frame(2, 'B')];
        final repo = FakeFrameRepository(
          frames: frames,
          order: ['1', '2'],
        );
        final provider = FrameProvider(repo);
        await pumpEventQueue();

        final originalActive = provider.activeFrame?.id;
        await provider.deleteFrame(2);

        expect(provider.activeFrame?.id, originalActive);
      });

      test('activeFrame is null after deleting last frame', () async {
        final frames = [_frame(1, 'Only')];
        final repo = FakeFrameRepository(
          frames: frames,
          order: ['1'],
        );
        final provider = FrameProvider(repo);
        await pumpEventQueue();

        await provider.deleteFrame(1);

        expect(provider.activeFrame, isNull);
        expect(provider.frames, isEmpty);
      });

      test('isLoading is false after deleteFrame completes', () async {
        final frames = [_frame(1, 'A')];
        final repo = FakeFrameRepository(frames: frames, order: ['1']);
        final provider = FrameProvider(repo);
        await pumpEventQueue();

        await provider.deleteFrame(1);

        expect(provider.isLoading, isFalse);
      });
    });

    group('setActiveFrame', () {
      test('updates active frame id', () async {
        final frames = [_frame(1, 'A'), _frame(2, 'B')];
        final repo = FakeFrameRepository(
          frames: frames,
          order: ['1', '2'],
        );
        final provider = FrameProvider(repo);
        await pumpEventQueue();

        provider.setActiveFrame(2);

        expect(provider.activeFrame?.id, 2);
      });

      test('throws FindFrameError for unknown id', () async {
        final frames = [_frame(1, 'A')];
        final repo = FakeFrameRepository(frames: frames, order: ['1']);
        final provider = FrameProvider(repo);
        await pumpEventQueue();

        expect(
          () => provider.setActiveFrame(999),
          throwsA(isA<FindFrameError>()),
        );
      });
    });

    group('orderFrames', () {
      test('moves frame from old position to new position (moving up)', () async {
        final frames = [
          _frame(1, 'A'),
          _frame(2, 'B'),
          _frame(3, 'C'),
        ];
        final repo = FakeFrameRepository(
          frames: frames,
          order: ['1', '2', '3'],
        );
        final provider = FrameProvider(repo);
        await pumpEventQueue();

        // Move frame at index 2 (C) to index 1 (moving up)
        await provider.orderFrames(2, 1);

        expect(provider.frames[1].id, 3);
      });

      test('handles index adjustment when moving DOWN (subtract 1 from target)', () async {
        final frames = [
          _frame(1, 'A'),
          _frame(2, 'B'),
          _frame(3, 'C'),
          _frame(4, 'D'),
        ];
        final repo = FakeFrameRepository(
          frames: frames,
          order: ['1', '2', '3', '4'],
        );
        final provider = FrameProvider(repo);
        await pumpEventQueue();

        // Move A (index 0) to position 3 (moving down). Because oldPos < newPos,
        // adjustedIndex = 3 - 1 = 2. So A ends up at index 2.
        await provider.orderFrames(0, 3);

        expect(provider.frames[2].id, 1);
      });

      test('persists order after reorder', () async {
        final frames = [_frame(1, 'A'), _frame(2, 'B'), _frame(3, 'C')];
        final repo = FakeFrameRepository(
          frames: frames,
          order: ['1', '2', '3'],
        );
        final provider = FrameProvider(repo);
        await pumpEventQueue();
        repo.setCalls.clear();

        await provider.orderFrames(0, 2);

        expect(repo.setCalls, isNotEmpty);
      });

      test('throws ReorderFrameError for negative oldPos', () async {
        final frames = [_frame(1, 'A'), _frame(2, 'B')];
        final repo = FakeFrameRepository(
          frames: frames,
          order: ['1', '2'],
        );
        final provider = FrameProvider(repo);
        await pumpEventQueue();

        expect(
          () => provider.orderFrames(-1, 1),
          throwsA(isA<ReorderFrameError>()),
        );
      });

      test('throws ReorderFrameError for out-of-bounds oldPos', () async {
        final frames = [_frame(1, 'A'), _frame(2, 'B')];
        final repo = FakeFrameRepository(
          frames: frames,
          order: ['1', '2'],
        );
        final provider = FrameProvider(repo);
        await pumpEventQueue();

        expect(
          () => provider.orderFrames(5, 1),
          throwsA(isA<ReorderFrameError>()),
        );
      });

      test('throws ReorderFrameError for negative newPos', () async {
        final frames = [_frame(1, 'A'), _frame(2, 'B')];
        final repo = FakeFrameRepository(
          frames: frames,
          order: ['1', '2'],
        );
        final provider = FrameProvider(repo);
        await pumpEventQueue();

        expect(
          () => provider.orderFrames(0, -1),
          throwsA(isA<ReorderFrameError>()),
        );
      });
    });

    group('isLoading toggles', () {
      test('isLoading is true during createFrame', () async {
        final repo = FakeFrameRepository(frames: [], order: []);
        final provider = FrameProvider(repo);
        await pumpEventQueue();

        bool loadingDuringCreate = false;
        provider.addListener(() {
          if (provider.isLoading) loadingDuringCreate = true;
        });

        await provider.createFrame(
          Frame(title: 'New', width: 4, height: 3, isCustom: true),
        );

        expect(loadingDuringCreate, isTrue);
        expect(provider.isLoading, isFalse);
      });

      test('isLoading is true during deleteFrame', () async {
        final frames = [_frame(1, 'A')];
        final repo = FakeFrameRepository(frames: frames, order: ['1']);
        final provider = FrameProvider(repo);
        await pumpEventQueue();

        bool loadingDuringDelete = false;
        provider.addListener(() {
          if (provider.isLoading) loadingDuringDelete = true;
        });

        await provider.deleteFrame(1);

        expect(loadingDuringDelete, isTrue);
        expect(provider.isLoading, isFalse);
      });
    });
  });
}
