import 'package:framatic/core/models/frame.dart';
import 'package:framatic/core/services/preferences_service.dart';
import 'package:framatic/core/utils/db.dart';
import 'package:framatic/features/frames_manager/data/frame_repository.dart';
import 'package:framatic/features/frames_manager/domain/frame_error.dart';

const _orderKey = 'frames_order';

class FrameService implements FrameRepository {
  final _db = FramaticDB.instance.db;

  @override
  Future<List<String>> getOrder() =>
      PreferencesService.getStringList(_orderKey);

  @override
  Future<void> setOrder(List<String> order) =>
      PreferencesService.setStringList(_orderKey, order);

  @override
  Future<List<Frame>> getAllFrames() async {
    final frames = await _db.query(FramesTable.name);
    return frames.map((frame) => Frame.fromJson(frame)).toList();
  }

  Future<Frame> getFrameById(int id) async {
    final frame = await _db.query(
      FramesTable.name,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (frame.isEmpty) {
      throw FindFrameError(
        'Frame not found with given id: $id',
        userMessage: 'Frame not found.',
      );
    }
    return Frame.fromJson(frame[0]);
  }

  @override
  Future<Frame> createFrame(Frame frame) async {
    final createdFrameId = await _db.insert(FramesTable.name, frame.toJson());
    if (createdFrameId == 0) {
      throw CreateFrameError(
        'Failed to create the frame',
        userMessage: 'Failed to create frame. Please try again.',
      );
    }
    return await getFrameById(createdFrameId);
  }

  @override
  Future<Frame> updateFrame(Frame frame) async {
    if (frame.id == null) {
      throw UpdateFrameError(
        'frame.id cannot be null for update operation',
        userMessage: 'Failed to update frame. Please try again.',
      );
    }
    final updatedFrameId = await _db.update(
      FramesTable.name,
      frame.toJson(),
      where: 'id = ?',
      whereArgs: [frame.id],
    );
    if (updatedFrameId == 0) {
      throw UpdateFrameError(
        'Failed to update the frame with id: ${frame.id}',
        userMessage: 'Failed to update frame. Please try again.',
      );
    }
    return await getFrameById(frame.id!);
  }

  @override
  Future<int> deleteFrame(int id) async {
    final deletedFrame = await _db.delete(
      FramesTable.name,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedFrame == 1) return id;
    throw DeleteFrameError(
      'Failed to delete the frame with given id: $id',
      userMessage: 'Failed to delete frame. Please try again.',
    );
  }
}
