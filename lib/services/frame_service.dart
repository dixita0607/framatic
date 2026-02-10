import 'package:framatic/db/db.dart';
import 'package:framatic/models/frame.dart';

class FrameService {
  final db = FramaticDB.instance.db;

  // getAllFrames
  Future<List<Frame>> getAllFrames() async {
    final frames = await db.query(FramesTable.name);
    return frames.map((frame) => Frame.fromJson(frame)).toList();
  }

  // getFrameById
  // createFrame
  // updateFrame
  // deleteFrame
}
