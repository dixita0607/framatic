import 'package:flutter/widgets.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

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

    final primary = SketchyTheme.of(context).primaryColor;

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: frames.length,
        itemBuilder: (context, index) {
          final frame = frames[index];
          final isSelected = activeFrame == frame;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SketchyChoiceChip(
              key: ValueKey('${frame.id}-$isSelected'),
              label: Text(frame.title),
              selected: isSelected,
              fillStyle: SketchyFill.hachure,
              backgroundColor: isSelected ? primary.withValues(alpha: 0.35) : null,
              onSelected: (selected) {
                if (selected) onFrameSelected(frame.id!);
              },
            ),
          );
        },
      ),
    );
  }
}
