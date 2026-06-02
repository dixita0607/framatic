import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/features/frames_manager/data/frame_repository.dart';
import 'package:framatic/features/frames_manager/domain/frame_error.dart';
import 'package:framatic/features/frames_manager/presentation/frame_provider.dart';

void main() {
  group('FrameProvider initialization', () {
    test(
      'applies saved order, removes stale ids, and appends new frames',
      () async {
        final repository = _FakeFrameRepository(
          frames: [
            _frame(id: 1, title: '16:9', width: 16, height: 9),
            _frame(id: 2, title: '4:3', width: 4, height: 3),
            _frame(id: 3, title: '1:1', width: 1, height: 1),
          ],
          order: ['2', '999'],
        );

        final provider = FrameProvider(repository);
        addTearDown(provider.dispose);

        await _waitForInitialization(provider);

        expect(provider.frames.map((frame) => frame.id), [2, 1, 3]);
        expect(provider.activeFrame?.id, 2);
        expect(repository.setOrderCalls, [
          ['2', '1', '3'],
        ]);
      },
    );

    test('does not rewrite a valid saved order', () async {
      final repository = _FakeFrameRepository(
        frames: [
          _frame(id: 1, title: '16:9', width: 16, height: 9),
          _frame(id: 2, title: '4:3', width: 4, height: 3),
        ],
        order: ['2', '1'],
      );

      final provider = FrameProvider(repository);
      addTearDown(provider.dispose);

      await _waitForInitialization(provider);

      expect(provider.frames.map((frame) => frame.id), [2, 1]);
      expect(repository.setOrderCalls, isEmpty);
    });
  });

  group('FrameProvider mutations', () {
    test('createFrame inserts new frame first and persists order', () async {
      final repository = _FakeFrameRepository(
        frames: [
          _frame(id: 1, title: '16:9', width: 16, height: 9),
          _frame(id: 2, title: '4:3', width: 4, height: 3),
        ],
        order: ['1', '2'],
      );
      final provider = FrameProvider(repository);
      addTearDown(provider.dispose);
      await _waitForInitialization(provider);
      repository.setOrderCalls.clear();

      final createdFrame = await provider.createFrame(
        Frame(title: 'Panorama', width: 3, height: 1, isCustom: true),
      );

      expect(createdFrame.id, 100);
      expect(provider.isLoading, isFalse);
      expect(provider.frames.map((frame) => frame.id), [100, 1, 2]);
      expect(repository.setOrderCalls, [
        ['100', '1', '2'],
      ]);
    });

    test(
      'updateFrame replaces matching frame without changing order',
      () async {
        final repository = _FakeFrameRepository(
          frames: [
            _frame(id: 1, title: '16:9', width: 16, height: 9),
            _frame(id: 2, title: 'Custom', width: 2, height: 1, isCustom: true),
          ],
          order: ['1', '2'],
        );
        final provider = FrameProvider(repository);
        addTearDown(provider.dispose);
        await _waitForInitialization(provider);

        final updatedFrame = await provider.updateFrame(
          _frame(id: 2, title: 'Cinema', width: 21, height: 9, isCustom: true),
        );

        expect(updatedFrame.title, 'Cinema');
        expect(provider.frames.map((frame) => frame.title), ['16:9', 'Cinema']);
        expect(provider.frames.map((frame) => frame.id), [1, 2]);
      },
    );

    test(
      'deleteFrame removes custom frame, moves active frame, and persists order',
      () async {
        final repository = _FakeFrameRepository(
          frames: [
            _frame(id: 1, title: '16:9', width: 16, height: 9),
            _frame(id: 2, title: '4:3', width: 4, height: 3),
            _frame(id: 3, title: 'Custom', width: 2, height: 1, isCustom: true),
          ],
          order: ['1', '2', '3'],
        );
        final provider = FrameProvider(repository);
        addTearDown(provider.dispose);
        await _waitForInitialization(provider);
        repository.setOrderCalls.clear();

        provider.setActiveFrame(3);
        await provider.deleteFrame(3);

        expect(provider.isLoading, isFalse);
        expect(provider.activeFrame?.id, 1);
        expect(provider.frames.map((frame) => frame.id), [1, 2]);
        expect(repository.deletedIds, [3]);
        expect(repository.setOrderCalls, [
          ['1', '2'],
        ]);
      },
    );

    test('updateFrame rejects predefined frames', () async {
      final repository = _FakeFrameRepository(
        frames: [
          _frame(id: 1, title: '16:9', width: 16, height: 9),
          _frame(id: 2, title: 'Custom', width: 2, height: 1, isCustom: true),
        ],
        order: ['1', '2'],
      );
      final provider = FrameProvider(repository);
      addTearDown(provider.dispose);
      await _waitForInitialization(provider);

      await expectLater(
        provider.updateFrame(_frame(id: 1, title: 'Wide', width: 2, height: 1)),
        throwsA(isA<UpdateFrameError>()),
      );

      expect(repository.updatedFrames, isEmpty);
      expect(provider.frames.map((frame) => frame.title), ['16:9', 'Custom']);
      expect(provider.isLoading, isFalse);
    });

    test('deleteFrame rejects predefined frames', () async {
      final repository = _FakeFrameRepository(
        frames: [
          _frame(id: 1, title: '16:9', width: 16, height: 9),
          _frame(id: 2, title: 'Custom', width: 2, height: 1, isCustom: true),
        ],
        order: ['1', '2'],
      );
      final provider = FrameProvider(repository);
      addTearDown(provider.dispose);
      await _waitForInitialization(provider);

      await expectLater(
        provider.deleteFrame(1),
        throwsA(isA<DeleteFrameError>()),
      );

      expect(repository.deletedIds, isEmpty);
      expect(provider.frames.map((frame) => frame.id), [1, 2]);
      expect(provider.isLoading, isFalse);
    });

    test('setActiveFrame throws when id is not loaded', () async {
      final repository = _FakeFrameRepository(
        frames: [_frame(id: 1, title: '16:9', width: 16, height: 9)],
        order: ['1'],
      );
      final provider = FrameProvider(repository);
      addTearDown(provider.dispose);
      await _waitForInitialization(provider);

      expect(
        () => provider.setActiveFrame(404),
        throwsA(isA<FindFrameError>()),
      );
      expect(provider.activeFrame?.id, 1);
    });
  });

  group('FrameProvider ordering', () {
    test('orderFrames supports moving a frame to the end', () async {
      final repository = _FakeFrameRepository(
        frames: [
          _frame(id: 1, title: '16:9', width: 16, height: 9),
          _frame(id: 2, title: '4:3', width: 4, height: 3),
          _frame(id: 3, title: '1:1', width: 1, height: 1),
        ],
        order: ['1', '2', '3'],
      );
      final provider = FrameProvider(repository);
      addTearDown(provider.dispose);
      await _waitForInitialization(provider);
      repository.setOrderCalls.clear();

      await provider.orderFrames(0, 3);

      expect(provider.isLoading, isFalse);
      expect(provider.frames.map((frame) => frame.id), [2, 3, 1]);
      expect(repository.setOrderCalls, [
        ['2', '3', '1'],
      ]);
    });

    test(
      'orderFrames rejects out-of-range indices without persisting',
      () async {
        final repository = _FakeFrameRepository(
          frames: [
            _frame(id: 1, title: '16:9', width: 16, height: 9),
            _frame(id: 2, title: '4:3', width: 4, height: 3),
          ],
          order: ['1', '2'],
        );
        final provider = FrameProvider(repository);
        addTearDown(provider.dispose);
        await _waitForInitialization(provider);
        repository.setOrderCalls.clear();

        expect(
          () => provider.orderFrames(-1, 1),
          throwsA(isA<ReorderFrameError>()),
        );
        expect(
          () => provider.orderFrames(0, 3),
          throwsA(isA<ReorderFrameError>()),
        );
        expect(provider.frames.map((frame) => frame.id), [1, 2]);
        expect(repository.setOrderCalls, isEmpty);
      },
    );
  });
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

Future<void> _waitForInitialization(FrameProvider provider) async {
  await pumpEventQueue(times: 5);
  expect(provider.isLoading, isFalse);
}

class _FakeFrameRepository implements FrameRepository {
  _FakeFrameRepository({
    required List<Frame> frames,
    List<String> order = const [],
  }) : _frames = List.of(frames),
       _order = List.of(order);

  final List<Frame> _frames;
  final List<List<String>> setOrderCalls = [];
  final List<int> deletedIds = [];
  final List<Frame> updatedFrames = [];

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
    final createdFrame = frame.id == null
        ? frame.copyWith(id: _nextId++)
        : frame;
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
