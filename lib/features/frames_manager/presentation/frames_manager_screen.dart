import 'package:flutter/widgets.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';
import 'package:framatic/features/frames_manager/presentation/frame_provider.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/frame_list_item.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/manage_frame_dialog.dart';
import 'package:provider/provider.dart';

class FramesManagerScreen extends StatelessWidget {
  const FramesManagerScreen({super.key});

  void _showAddFrameDialog(BuildContext context, FrameProvider frameProvider) {
    showSketchDialog(
      context: context,
      builder: (context) => ManageFrameDialog(
        existingFrames: frameProvider.frames,
        onSave: (newFrame) async {
          await frameProvider.createFrame(newFrame);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SketchScreen(
      title: 'Manage Frames',
      onBack: () => Navigator.of(context).pop(),
      child: Consumer<FrameProvider>(
        builder: (context, frameProvider, child) {
          if (frameProvider.isLoading) {
            return const Center(child: SketchProgress(size: 36));
          }

          final allFrames = frameProvider.frames;

          return Stack(
            children: [
              Semantics(
                label: 'Frames are ordered for camera quick access',
                child: ReorderableList(
                  itemCount: allFrames.length,
                  padding: const EdgeInsets.fromLTRB(14, 6, 24, 92),
                  onReorderItem: (oldIndex, newIndex) async {
                    final providerNewIndex = oldIndex < newIndex
                        ? newIndex + 1
                        : newIndex;
                    await frameProvider.orderFrames(oldIndex, providerNewIndex);
                  },
                  itemBuilder: (context, index) {
                    final frame = allFrames[index];
                    return FrameListItem(
                      key: ValueKey(frame.id),
                      frame: frame,
                      existingFrames: allFrames,
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
              // TODO: Add feedback reporting with diagnostics once a real
              // support destination is available.
              Positioned(
                right: 18,
                bottom: 18,
                child: SketchIconButton(
                  icon: SketchIconType.add,
                  onPressed: () => _showAddFrameDialog(context, frameProvider),
                  tooltip: 'Add Custom Frame',
                  size: 50,
                  filled: true,
                  primary: true,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
