import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:framatic/models/frame_preset.dart';
import 'package:framatic/providers/frame_provider.dart';
import 'package:framatic/widgets/custom_frame_dialog.dart';

class PresetManagerScreen extends StatelessWidget {
  const PresetManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Frames'),
      ),
      body: Consumer<FrameProvider>(
        builder: (context, frameProvider, child) {
          if (frameProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final allFrames = frameProvider.allPresets;

          return ReorderableListView.builder(
            itemCount: allFrames.length,
            onReorder: (oldIndex, newIndex) {
              // Handle reordering - don't await to avoid blocking the animation
              // The provider updates the UI immediately and persists in background
              final List<FramePreset> items = List.from(allFrames);
              final FramePreset item = items.removeAt(oldIndex);

              // Adjust newIndex when dragging down: ReorderableListView reports the index
              // AFTER removal, so we need to subtract 1 when moving to a higher index
              var adjustedIndex = newIndex;
              if (oldIndex < newIndex) {
                adjustedIndex -= 1;
              }

              items.insert(adjustedIndex, item);

              // Fire and forget - UI updates immediately, persistence happens in background
              frameProvider.reorderPresets(items);
            },
            itemBuilder: (context, index) {
              final preset = allFrames[index];
              // Check if custom using preset's own property (not position-based)
              // This works correctly even after reordering
              final isPredefined = !preset.isCustom;

              return RepaintBoundary(
                key: ValueKey(preset.id ?? preset.name),
                child: _buildPresetTile(
                  context,
                  preset: preset,
                  frameProvider: frameProvider,
                  isPredefined: isPredefined,
                  dragIndex: index,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCustomPresetDialog(context),
        tooltip: 'Add Custom Preset',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPresetTile(
    BuildContext context, {
    required FramePreset preset,
    required FrameProvider frameProvider,
    required bool isPredefined,
    required int dragIndex,
  }) {
    // Use same key as parent RepaintBoundary to ensure PopupMenuButton state is properly tracked
    final itemKey = ValueKey(preset.id ?? preset.name);

    return ReorderableDragStartListener(
      index: dragIndex,
      child: ListTile(
        key: itemKey,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.drag_handle),
            const SizedBox(width: 8),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: CustomPaint(
                painter: _PresetPreviewPainter(preset.aspectRatio),
              ),
            ),
          ],
        ),
        title: Text(preset.name),
        subtitle: Text(preset.formattedRatio),
        trailing: !isPredefined
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditCustomPresetDialog(context, preset);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(context, preset, frameProvider);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  void _showAddCustomPresetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CustomFrameDialog(),
    );
  }

  void _showEditCustomPresetDialog(BuildContext context, FramePreset preset) {
    showDialog(
      context: context,
      builder: (context) => CustomFrameDialog(existingPreset: preset),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    FramePreset preset,
    FrameProvider frameProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Frame'),
        content: Text('Are you sure you want to delete "${preset.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final presetId = preset.id;
              if (presetId == null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cannot delete: preset has no ID. Please recreate this preset.'),
                    ),
                  );
                }
                return;
              }
              final success = await frameProvider.deleteCustomPreset(presetId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Frame deleted'
                          : 'Failed to delete frame',
                    ),
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// Custom painter to preview frame aspect ratio
class _PresetPreviewPainter extends CustomPainter {
  final double aspectRatio;

  _PresetPreviewPainter(this.aspectRatio);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Calculate frame size
    double frameWidth = size.width * 0.8;
    double frameHeight = frameWidth / aspectRatio;

    if (frameHeight > size.height * 0.8) {
      frameHeight = size.height * 0.8;
      frameWidth = frameHeight * aspectRatio;
    }

    final frameRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: frameWidth,
      height: frameHeight,
    );

    // Draw outer area
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(frameRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
    canvas.drawRect(frameRect, borderPaint);
  }

  @override
  bool shouldRepaint(_PresetPreviewPainter oldDelegate) {
    return oldDelegate.aspectRatio != aspectRatio;
  }
}
