import 'package:flutter/foundation.dart';
import 'package:framatic/models/frame.dart';
import 'package:framatic/services/frame_service.dart';

class FrameProvider extends ChangeNotifier {
  final FrameService _frameService = FrameService();

  List<Frame> _frames = [];
  bool _isLoading = false;

  List<Frame> get frames => _frames;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    // Start loading
    _isLoading = true;
    notifyListeners();

    // Fetch frames
    _frames = await _frameService.getAllFrames();
    _isLoading = false;
    notifyListeners();
  }
}
