import 'package:framatic/models/frame.dart';
import 'package:framatic/services/preferences_service.dart';
import 'package:framatic/utils/db.dart';

const _orderKey = 'frames_order';

class FrameService {
  final _db = FramaticDB.instance.db;

  Future<List<String>> getOrder() =>
      PreferencesService.getStringList(_orderKey);

  Future<void> setOrder(List<String> order) =>
      PreferencesService.setStringList(_orderKey, order);

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
      throw StateError('Frame not found with given id: $id');
    }
    return Frame.fromJson(frame[0]);
  }

  Future<Frame> createFrame(Frame frame) async {
    final createdFrameId = await _db.insert(FramesTable.name, frame.toJson());
    if (createdFrameId == 0) throw StateError('Failed to create the frame');
    return await getFrameById(createdFrameId);
  }

  Future<Frame> updateFrame(Frame frame) async {
    if (frame.id == null) {
      throw ArgumentError('frame.id cannot be null for update operation');
    }
    final updatedFrameId = await _db.update(
      FramesTable.name,
      frame.toJson(),
      where: 'id = ?',
      whereArgs: [frame.id],
    );
    if (updatedFrameId == 0) {
      throw StateError('Failed to update the frame with id: ${frame.id}');
    }
    return await getFrameById(frame.id!);
  }

  Future<int> deleteFrame(int id) async {
    final deletedFrame = await _db.delete(
      FramesTable.name,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedFrame == 1) return id;
    throw StateError('Failed to delete the frame with given id: $id');
  }
}
