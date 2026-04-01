import 'package:framatic/core/models/frame.dart';

abstract interface class FrameRepository {
  Future<List<String>> getOrder();
  Future<void> setOrder(List<String> order);
  Future<List<Frame>> getAllFrames();
  Future<Frame> createFrame(Frame frame);
  Future<Frame> updateFrame(Frame frame);
  Future<int> deleteFrame(int id);
}
