import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:framatic/models/frame.dart';
import 'package:framatic/providers/frame_provider.dart';
import 'package:provider/provider.dart';

class CustomFrameDialog extends StatefulWidget {
  final Frame? existingPreset;

  const CustomFrameDialog({super.key, this.existingPreset});

  @override
  State<CustomFrameDialog> createState() => _CustomFrameDialogState();
}

class _CustomFrameDialogState extends State<CustomFrameDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.existingPreset != null;

    if (_isEditing) {
      _nameController.text = widget.existingPreset!.title;
      _widthController.text = widget.existingPreset!.width.toString();
      _heightController.text = widget.existingPreset!.height.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Frame' : 'Add Custom Frame'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Frame Name',
                    hintText: 'e.g., "My Custom Frame"',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Frame name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Aspect ratio input
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _widthController,
                        decoration: const InputDecoration(
                          labelText: 'Width',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter width';
                          }
                          final number = int.tryParse(value);
                          if (number == null || number <= 0) {
                            return 'Must be > 0';
                          }
                          return null;
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(':', style: TextStyle(fontSize: 24)),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _heightController,
                        decoration: const InputDecoration(
                          labelText: 'Height',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter height';
                          }
                          final number = int.tryParse(value);
                          if (number == null || number <= 0) {
                            return 'Must be > 0';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _savePreset,
          child: Text(_isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  void _savePreset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final width = int.parse(_widthController.text);
    final height = int.parse(_heightController.text);

    final frameProvider = context.read<FrameProvider>();

    try {
      if (_isEditing) {
        // Update existing frame with its ID
        final updatedFrame = Frame(
          id: widget.existingPreset!.id,
          title: name,
          width: width,
          height: height,
          isCustom: true,
        );
        await frameProvider.updateFrame(updatedFrame);
      } else {
        // Create new frame without ID (database will auto-generate)
        final newFrame = Frame(
          title: name,
          width: width,
          height: height,
          isCustom: true,
        );
        await frameProvider.createFrame(newFrame);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Frame updated' : 'Frame added',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save frame: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
