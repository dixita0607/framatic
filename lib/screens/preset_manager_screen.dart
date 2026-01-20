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
        title: const Text('Manage Frame Presets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCustomPresetDialog(context),
            tooltip: 'Add Custom Preset',
          ),
        ],
      ),
      body: Consumer<FrameProvider>(
        builder: (context, frameProvider, child) {
          if (frameProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: [
              // Predefined Presets Section
              _buildSection(
                context,
                title: 'Predefined Frames',
                presets: frameProvider.predefinedPresets,
                frameProvider: frameProvider,
                isPredefined: true,
              ),

              const Divider(height: 32),

              // Custom Presets Section
              _buildSection(
                context,
                title: 'Custom Frames',
                presets: frameProvider.customPresets,
                frameProvider: frameProvider,
                isPredefined: false,
              ),

              if (frameProvider.customPresets.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Text(
                      'No custom frames yet.\nTap + to create one.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<FramePreset> presets,
    required FrameProvider frameProvider,
    required bool isPredefined,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...presets.map((preset) => _buildPresetTile(
              context,
              preset: preset,
              frameProvider: frameProvider,
              isPredefined: isPredefined,
            )),
      ],
    );
  }

  Widget _buildPresetTile(
    BuildContext context, {
    required FramePreset preset,
    required FrameProvider frameProvider,
    required bool isPredefined,
  }) {
    final presetId = preset.id ?? preset.name;
    final isFavorite = frameProvider.isFavorite(presetId);
    final isActive = frameProvider.activePreset == preset;

    return ListTile(
      leading: Container(
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
      title: Text(preset.name),
      subtitle: Text(preset.formattedRatio),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Favorite icon
          IconButton(
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite ? Colors.amber : Colors.grey,
            ),
            onPressed: () => frameProvider.toggleFavorite(presetId),
          ),

          // Active indicator
          if (isActive)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.check_circle, color: Colors.green),
            ),

          // Edit/delete menu for custom presets (always shown)
          if (!isPredefined)
            PopupMenuButton<String>(
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
            ),
        ],
      ),
      onTap: () {
        frameProvider.setActivePreset(preset);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Active frame: ${preset.name}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
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
