import 'package:flutter/material.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

/// Widget for quick frame switching with horizontal scroll
class FrameSelector extends StatelessWidget {
  final List<Frame> frames;
  final Frame activeFrame;
  final bool isLoading;
  final Function(int frameId) onFrameSelected;

  const FrameSelector({
    super.key,
    required this.frames,
    required this.activeFrame,
    required this.isLoading,
    required this.onFrameSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 40,
        child: Center(child: SketchyCircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: .horizontal,
        itemCount: frames.length,
        itemBuilder: (context, index) {
          final frame = frames[index];
          final isSelected = activeFrame == frame;
          return Padding(
            padding: const .symmetric(horizontal: 4),
            child: GestureDetector(
              child: SketchyFrame(
                padding: EdgeInsetsGeometry.all(8),
                fillColor: isSelected
                    ? SketchyTheme.of(context).secondaryColor
                    : SketchyColors.transparent,
                fill: .hachure,
                strokeColor: isSelected
                    ? SketchyTheme.of(context).primaryColor
                    : SketchyTheme.of(context).inkColor,
                cornerRadius: 20,
                child: SketchyText(frame.title),
              ),
              onTap: () => onFrameSelected(frame.id!),
            ),
          );
        },
      ),
    );
  }
}
