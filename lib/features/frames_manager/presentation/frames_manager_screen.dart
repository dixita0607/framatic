import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:framatic/features/frames_manager/presentation/frame_provider.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/frame_list_item.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/manage_frame_dialog.dart';
import 'package:provider/provider.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

class FramesManagerScreen extends StatelessWidget {
  const FramesManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SketchyScaffold(
      appBar: SketchyAppBar(
        title: const SketchyText('Manage Frames'),
        leading: RotatedBox(
          quarterTurns: 2,
          child: GestureDetector(
            child: SketchySymbol(symbol: .chevronRight),
            onTap: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Consumer<FrameProvider>(
        builder: (context, frameProvider, child) {
          if (frameProvider.isLoading) {
            return const Center(child: SketchyCircularProgressIndicator());
          }

          final allFrames = frameProvider.frames;

          return SketchyScaffold(
            body: Padding(
              padding: .all(16),
              child: ListView.builder(
                itemCount: allFrames.length,
                // onReorder: (oldIndex, newIndex) async =>
                //     await frameProvider.orderFrames(oldIndex, newIndex),
                itemBuilder: (context, index) {
                  final frame = allFrames[index];
                  return DraggableFrameListItem(
                    key: ValueKey(frame.id),
                    frame: frame,
                    order: index,
                    onEdit: (updatedFrame) async {
                      await frameProvider.updateFrame(updatedFrame);
                    },
                    onDelete: (frameId) async {
                      await frameProvider.deleteFrame(frameId);
                    },
                  );
                },
              ),
            ),
            floatingActionButton: SketchyButton(
              onPressed: () => unawaited(
                showGeneralDialog(
                  context: context,
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      SketchyDialog(
                        child: ManageFrameDialog(
                          onSave: (newFrame) async {
                            await frameProvider.createFrame(newFrame);
                          },
                        ),
                      ),
                ),
              ),
              tooltip: 'Add Custom Frame',
              child: const SketchySymbol(symbol: .plus),
            ),
          );
        },
      ),
    );
  }
}
