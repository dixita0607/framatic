import 'package:flutter/material.dart';
import 'package:framatic/core/models/frame.dart';

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
        child: Center(child: CircularProgressIndicator()),
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
            child: ChoiceChip(
              label: Text(frame.title),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onFrameSelected(frame.id!);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
