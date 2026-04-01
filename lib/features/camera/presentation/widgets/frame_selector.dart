import 'package:flutter/material.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/features/frames_manager/presentation/frame_provider.dart';
import 'package:provider/provider.dart';

/// Widget for quick frame switching with horizontal scroll
class FrameSelector extends StatelessWidget {
  const FrameSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FrameProvider>(
      builder: (context, frameProvider, child) {
        if (frameProvider.isLoading) {
          return const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final presets = frameProvider.frames;

        return SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: presets.length,
            itemBuilder: (context, index) {
              final preset = presets[index];
              final isSelected = frameProvider.activeFrame == preset;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(preset.title),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      frameProvider.setActiveFrame(preset.id!);
                    }
                  },
                  selectedColor: Colors.white,
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Bottom sheet version for more detailed preset selection
class FrameSelectorBottomSheet extends StatelessWidget {
  const FrameSelectorBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withValues(alpha: 0.9),
      builder: (context) => const FrameSelectorBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FrameProvider>(
      builder: (context, frameProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'All Frames',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              _buildPresetGrid(context, frameProvider.frames, frameProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPresetGrid(
    BuildContext context,
    List<Frame> presets,
    FrameProvider frameProvider,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presets.map((preset) {
        final isSelected = frameProvider.activeFrame == preset;
        return ChoiceChip(
          label: Text(preset.title),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              frameProvider.setActiveFrame(preset.id!);
              Navigator.of(context).pop();
            }
          },
          selectedColor: Colors.white,
          backgroundColor: Colors.grey.withValues(alpha: 0.3),
          labelStyle: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}
