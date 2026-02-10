import 'package:flutter/foundation.dart';
import 'package:framatic/models/frame.dart';
import 'package:framatic/services/frame_service.dart';

class FrameProvider extends ChangeNotifier {
  final FrameService _frameService = FrameService();

  List<Frame> _frames = [];
  bool _isLoading = false;
  late int _activeFrameId;

  List<Frame> get frames => _frames;
  bool get isLoading => _isLoading;
  Frame? get activeFrameId {
    try {
      return _frames.firstWhere((frame) => frame.id == _activeFrameId);
    } catch (e) {
      return null;
    }
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _frames = await _frameService.getAllFrames();
      if (_frames.isNotEmpty) {
        _activeFrameId = _frames[0].id!;
      }
    } catch (e) {
      debugPrint('Error initializing FrameProvider: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Frame> createFrame(Frame newFrame) async {
    _isLoading = true;
    notifyListeners();
    try {
      final createdFrame = await _frameService.createFrame(newFrame);
      _frames.add(createdFrame);
      notifyListeners();
      return createdFrame;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Frame> updateFrame(Frame frame) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updatedFrame = await _frameService.updateFrame(frame);

      final updatedFrameIndex = _frames.indexWhere((f) => f.id == frame.id);
      if (updatedFrameIndex != -1) {
        _frames[updatedFrameIndex] = updatedFrame;
        notifyListeners();
      }

      return updatedFrame;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteFrame(int frameId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _frameService.deleteFrame(frameId);
      _frames.removeWhere((frame) => frame.id == frameId);

      // If deleted frame was selected, switch to first available
      if (_activeFrameId == frameId) {
        _activeFrameId = _frames.isNotEmpty ? _frames[0].id! : 0;
      }
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set the currently active/selected frame
  /// Throws [StateError] if frame with given ID is not found
  void setActiveFrame(int frameId) {
    final frameExists = _frames.any((frame) => frame.id == frameId);
    if (!frameExists) {
      throw StateError('Frame with id $frameId not found');
    }
    _activeFrameId = frameId;
    notifyListeners();
  }

  /// Reorder frames and update local state
  /// TODO: Persist order to shared_preferences
  void orderFrames(List<Frame> orderedFrames) {
    _frames = orderedFrames;
    notifyListeners();
    // Order persistence to be implemented with shared_preferences
  }
}
