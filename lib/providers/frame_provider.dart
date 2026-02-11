import 'package:flutter/foundation.dart';
import 'package:framatic/models/frame.dart';
import 'package:framatic/services/frame_order_service.dart';
import 'package:framatic/services/frame_service.dart';

class FrameProvider extends ChangeNotifier {
  final FrameService _frameService = FrameService();

  List<Frame> _frames = [];
  bool _isLoading = false;
  late int _activeFrameId;

  List<Frame> get frames => _frames;
  bool get isLoading => _isLoading;
  Frame? get activeFrame {
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
      await _orderFrames();
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

      _frames.insert(0, createdFrame);
      notifyListeners();

      await FrameOrderService.setOrder([
        createdFrame.id.toString(),
        ...FrameOrderService.order,
      ]);
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
      if (_activeFrameId == frameId) {
        _activeFrameId = _frames.isNotEmpty ? _frames[0].id! : 0;
      }
      notifyListeners();

      await FrameOrderService.setOrder(
        FrameOrderService.order
            .where((id) => id != frameId.toString())
            .toList(),
      );
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

      // Persist to shared preferences
      await FrameOrderService.setOrder(
        _frames.map((frame) => frame.id.toString()).toList(),
      );
    } catch (e) {
      debugPrint('Error reordering frames: $e');
      rethrow;
    }
  }

  Future<void> _orderFrames() async {
    var savedOrder = FrameOrderService.order;

    if (savedOrder.isEmpty && _frames.isNotEmpty) {
      savedOrder = _frames.map((f) => f.id.toString()).toList();
      await FrameOrderService.setOrder(savedOrder);
    }

    final frameMap = Map.fromEntries(
      _frames.map((frame) => MapEntry(frame.id.toString(), frame)),
    );

    _frames = savedOrder.map((frameIdStr) => frameMap[frameIdStr]!).toList();
  }
}
