import 'package:flutter/widgets.dart';
import 'package:framatic/core/utils/color_utils.dart';
import 'package:framatic/core/utils/dialog_utils.dart';
import 'package:framatic/core/widgets/dotted_background.dart';
import 'package:framatic/features/frames_manager/presentation/frame_provider.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/frame_list_item.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/manage_frame_dialog.dart';
import 'package:provider/provider.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

class FramesManagerScreen extends StatefulWidget {
  const FramesManagerScreen({super.key});

  @override
  State<FramesManagerScreen> createState() => _FramesManagerScreenState();
}

class _FramesManagerScreenState extends State<FramesManagerScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _showAddFrameDialog(
      BuildContext context, FrameProvider frameProvider) async {
    await showSketchyDialog(
      context: context,
      builder: (context) => ManageFrameDialog(
        existingTitles: frameProvider.frames.map((f) => f.title).toList(),
        onSave: (newFrame) async {
          await frameProvider.createFrame(newFrame);
        },
      ),
    );
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ink = SketchyTheme.of(context).inkColor;
    final primary = SketchyTheme.of(context).primaryColor;
    return DottedScaffold(
      appBar: SketchyAppBar(
        title: const Text('Frames'),
        leading: Semantics(
          button: true,
          label: 'Back',
          child: SketchyIconButton(
            icon: RotatedBox(
              quarterTurns: 2,
              child: SketchySymbol(
                  symbol: SketchySymbols.chevronRight, color: ink),
            ),
            iconSize: 40,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Consumer<FrameProvider>(
        builder: (context, frameProvider, child) {
          if (frameProvider.isLoading) {
            return const Center(child: SketchyCircularProgressIndicator());
          }

          final allFrames = frameProvider.frames;
          final existingTitles = allFrames.map((f) => f.title).toList();

          return Stack(
            children: [
              ReorderableList(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                itemCount: allFrames.length,
                onReorder: (oldIndex, newIndex) async =>
                    await frameProvider.orderFrames(oldIndex, newIndex),
                itemBuilder: (context, index) {
                  final frame = allFrames[index];
                  return FrameListItem(
                    key: ValueKey(frame.id),
                    frame: frame,
                    order: index,
                    existingTitles: existingTitles,
                    onEdit: (updatedFrame) async {
                      await frameProvider.updateFrame(updatedFrame);
                    },
                    onDelete: (frameId) async {
                      await frameProvider.deleteFrame(frameId);
                    },
                  );
                },
              ),
              if (frameProvider.isMutating)
                AbsorbPointer(
                  child: const ColoredBox(
                    color: Color(0x20000000),
                    child: SizedBox.expand(),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Semantics(
        button: true,
        label: 'Add frame',
        child: GestureDetector(
          key: const Key('add_frame_fab'),
          onTap: () =>
              _showAddFrameDialog(context, context.read<FrameProvider>()),
          child: SketchyFrame(
            shape: SketchyFrameShape.circle,
            width: 56,
            height: 56,
            fill: SketchyFill.solid,
            fillColor: primary,
            strokeColor: primary,
            child: Center(
              child: SketchySymbol(
                  symbol: SketchySymbols.plus, color: onColor(primary)),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: SketchyFabLocation.endFloat,
    );
  }
}
