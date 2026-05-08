import 'package:flutter/material.dart';
import 'package:framatic/features/frames_manager/presentation/frame_provider.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/frame_list_item.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/manage_frame_dialog.dart';
import 'package:provider/provider.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

class FramesManagerScreen extends StatelessWidget {
  const FramesManagerScreen({super.key});

  void _showAddFrameDialog(BuildContext context, FrameProvider frameProvider) {
    showDialog(
      context: context,
      builder: (context) => ManageFrameDialog(
        onSave: (newFrame) async {
          await frameProvider.createFrame(newFrame);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ink = SketchyTheme.of(context).inkColor;
    final primary = SketchyTheme.of(context).primaryColor;
    return SketchyScaffold(
      appBar: SketchyAppBar(
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(Icons.arrow_back, color: ink),
          ),
        ),
        title: const Text('Manage Frames'),
      ),
      body: Consumer<FrameProvider>(
        builder: (context, frameProvider, child) {
          if (frameProvider.isLoading) {
            return const Center(child: SketchyCircularProgressIndicator());
          }

          final allFrames = frameProvider.frames;

          return Material(
            type: MaterialType.transparency,
            child: ReorderableListView.builder(
              itemCount: allFrames.length,
              onReorder: (oldIndex, newIndex) async =>
                  await frameProvider.orderFrames(oldIndex, newIndex),
              itemBuilder: (context, index) {
                final frame = allFrames[index];
                return FrameListItem(
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
          );
        },
      ),
      floatingActionButton: GestureDetector(
        onTap: () => _showAddFrameDialog(context, context.read<FrameProvider>()),
        child: SketchyFrame(
          shape: SketchyFrameShape.circle,
          width: 56,
          height: 56,
          fill: SketchyFill.solid,
          fillColor: primary,
          strokeColor: primary,
          child: const Center(
            child: Icon(Icons.add, color: Color(0xFF000000)),
          ),
        ),
      ),
      floatingActionButtonLocation: SketchyFabLocation.endFloat,
    );
  }
}
