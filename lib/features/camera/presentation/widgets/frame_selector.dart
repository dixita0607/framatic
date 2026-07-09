import 'package:flutter/widgets.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';

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
      return const SizedBox(height: 40, child: Center(child: SketchProgress()));
    }

    return SizedBox(
      height: 54,
      child: ListView.builder(
        scrollDirection: .horizontal,
        itemCount: frames.length,
        itemBuilder: (context, index) {
          final frame = frames[index];
          final isSelected = activeFrame == frame;

          return Padding(
            padding: const .symmetric(horizontal: 4),
            child: Builder(
              builder: (chipContext) {
                return SketchChip(
                  key: ValueKey('frame_selector_${frame.id}'),
                  label: frame.title,
                  selected: isSelected,
                  semanticLabel:
                      '${frame.title}, ${frame.formattedRatio}${isSelected ? ', selected' : ''}',
                  onSelected: () {
                    onFrameSelected(frame.id!);
                    Scrollable.ensureVisible(
                      chipContext,
                      alignment: 0.5,
                      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
