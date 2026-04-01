import 'package:flutter/foundation.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/features/frames_manager/data/frame_repository.dart';

class FrameProvider extends ChangeNotifier {
  final FrameRepository _frameRepository;

  List<Frame> _frames = [];
  bool _isLoading = false;
  int? _activeFrameId;

  FrameProvider(FrameRepository frameRepository)
    : _frameRepository = frameRepository {
    _initialize();
  }

  List<Frame> get frames => _frames;
  bool get isLoading => _isLoading;
  Frame? get activeFrame => _activeFrameId == null
      ? null
      : _frames.where((frame) => frame.id == _activeFrameId).firstOrNull;

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _frames = await _frameRepository.getAllFrames();
      await _initializeFrameOrder();
      if (_frames.isNotEmpty) {
        _activeFrameId = _frames[0].id!;
      }
    } catch (e) {
      debugPrint('Error initializing frames: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Frame> createFrame(Frame newFrame) async {
    _isLoading = true;
    notifyListeners();
    try {
      final createdFrame = await _frameRepository.createFrame(newFrame);
      _frames.insert(0, createdFrame);
      await _frameRepository.setOrder(
        _frames.map((f) => f.id.toString()).toList(),
      );
      return createdFrame;
    } catch (e) {
      debugPrint('Error creating frame: $e');
      throw StateError('Failed to create frame. Please try again.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Frame> updateFrame(Frame frame) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updatedFrame = await _frameRepository.updateFrame(frame);
      final updatedFrameIndex = _frames.indexWhere((f) => f.id == frame.id);
      if (updatedFrameIndex != -1) {
        _frames[updatedFrameIndex] = updatedFrame;
      }
      return updatedFrame;
    } catch (e) {
      debugPrint('Error updating frame: $e');
      throw StateError('Failed to update frame. Please try again.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteFrame(int frameId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _frameRepository.deleteFrame(frameId);
      _frames.removeWhere((frame) => frame.id == frameId);
      if (_activeFrameId != null && _activeFrameId == frameId) {
        _activeFrameId = _frames.isNotEmpty ? _frames[0].id : null;
      }
      await _frameRepository.setOrder(
        _frames.map((f) => f.id.toString()).toList(),
      );
    } catch (e) {
      debugPrint('Error deleting frame: $e');
      throw StateError('Failed to delete frame. Please try again.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setActiveFrame(int frameId) {
    final frameExists = _frames.any((frame) => frame.id == frameId);
    if (!frameExists) {
      throw StateError('Frame with id $frameId not found');
    }
    _activeFrameId = frameId;
    notifyListeners();
  }

  // Intentionally optimistic: no `isLoading` flag so the drag interaction
  // isn't interrupted by a loading state. The list is updated in-memory
  // immediately and persisted in the background.
  Future<void> orderFrames(int oldPos, int newPos) async {
    if (oldPos < 0 ||
        oldPos >= _frames.length ||
        newPos < 0 ||
        newPos > _frames.length) {
      throw ArgumentError(
        'Invalid reorder indices: oldPos=$oldPos, newPos=$newPos, length=${_frames.length}',
      );
    }

    try {
      final frameToMove = _frames.removeAt(oldPos);
      var adjustedIndex = newPos;
      if (oldPos < newPos) {
        adjustedIndex -= 1;
      }
      _frames.insert(adjustedIndex, frameToMove);
      notifyListeners();

      await _frameRepository.setOrder(
        _frames.map((frame) => frame.id.toString()).toList(),
      );
    } catch (e) {
      debugPrint('Error reordering frames: $e');
      throw StateError('Failed to reorder frames. Please try again.');
    }
  }

  Future<void> _initializeFrameOrder() async {
    if (_frames.isEmpty) return;

    final orderedIds = await _frameRepository.getOrder();
    final frameIds = _frames.map((f) => f.id.toString()).toSet();

    // Keep only IDs that exist in DB, then append any new DB IDs not yet in order.
    final validOrder = orderedIds.where(frameIds.contains).toList();
    final newDbIds = frameIds.difference(orderedIds.toSet()).toList();
    final finalOrder = [...validOrder, ...newDbIds];

    // Only persist if stale IDs were removed or new DB IDs were added.
    if (validOrder.length != orderedIds.length || newDbIds.isNotEmpty) {
      await _frameRepository.setOrder(finalOrder);
    }

    final frameMap = {for (final f in _frames) f.id.toString(): f};
    _frames = finalOrder.map((id) => frameMap[id]!).toList();
  }
}
