import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/core/extensions/error_extension.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';

class ManageFrameDialog extends StatefulWidget {
  final Frame? frame;
  final Function(Frame) onSave;

  const ManageFrameDialog({super.key, this.frame, required this.onSave});

  @override
  State<ManageFrameDialog> createState() => _ManageFrameDialogState();
}

class _ManageFrameDialogState extends State<ManageFrameDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.frame != null;

    if (_isEditing) {
      _nameController.text = widget.frame!.title;
      _widthController.text = widget.frame!.width.toString();
      _heightController.text = widget.frame!.height.toString();
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
    return SketchDialog(
      title: _isEditing ? 'Edit Frame' : 'Add Frame',
      actions: [
        SketchButton(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
        SketchButton(
          label: 'Save',
          onPressed: _saveFrame,
          filled: true,
          primary: true,
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: .min,
          children: [
            SketchFormInput(
              controller: _nameController,
              label: 'Frame Name',
              hint: 'e.x. Ultra Wide',
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
                  child: SketchFormInput(
                    controller: _widthController,
                    keyboardType: .number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    label: 'Width',
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
                const SizedBox(width: 8),
                Expanded(
                  child: SketchFormInput(
                    controller: _heightController,
                    keyboardType: .number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    label: 'Height',
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
    );
  }

  void _saveFrame() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final width = int.parse(_widthController.text);
    final height = int.parse(_heightController.text);

    try {
      final frame = Frame(
        id: _isEditing ? widget.frame!.id : null,
        title: name,
        width: width,
        height: height,
        isCustom: true,
      );

      await widget.onSave(frame);

      if (mounted) {
        Navigator.of(context).pop();
        SketchToast.show(context, _isEditing ? 'Frame updated' : 'Frame added');
      }
    } on AppError catch (e) {
      if (mounted) {
        context.showErrorToast(e);
      }
    }
  }
}
