import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/core/extensions/error_extension.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/core/widgets/filled_sketchy_button.dart';
import 'package:framatic/core/widgets/sketchy_underline.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

class ManageFrameDialog extends StatefulWidget {
  final Frame? frame;
  final Function(Frame) onSave;

  const ManageFrameDialog({super.key, this.frame, required this.onSave});

  @override
  State<ManageFrameDialog> createState() => _ManageFrameDialogState();
}

class _ManageFrameDialogState extends State<ManageFrameDialog> {
  final _nameController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();

  bool _isEditing = false;
  String? _nameError;
  String? _widthError;
  String? _heightError;

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
    final primary = SketchyTheme.of(context).primaryColor;
    final secondary = SketchyTheme.of(context).secondaryColor;
    final ink = SketchyTheme.of(context).inkColor;

    return SketchyDialog(
      child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing ? 'Edit Frame' : 'Add Frame',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              SketchyUnderline(color: ink),
              const SizedBox(height: 20),
              SketchyTextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Frame Name',
                  errorText: _nameError,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SketchyTextField(
                      controller: _widthController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Width',
                        errorText: _widthError,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SketchyTextField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Height',
                        errorText: _heightError,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledSketchyButton(
                    fillColor: secondary,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledSketchyButton(
                    fillColor: primary,
                    onPressed: _saveFrame,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
      ),
    );
  }

  void _saveFrame() async {
    setState(() {
      _nameError = null;
      _widthError = null;
      _heightError = null;
    });

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Frame name is required');
      return;
    }

    final width = int.tryParse(_widthController.text);
    if (width == null || width <= 0) {
      setState(() => _widthError = 'Must be > 0');
      return;
    }

    final height = int.tryParse(_heightController.text);
    if (height == null || height <= 0) {
      setState(() => _heightError = 'Must be > 0');
      return;
    }

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
        SketchySnackBar.show(
          context,
          message: _isEditing ? 'Frame updated' : 'Frame added',
        );
      }
    } on AppError catch (e) {
      if (mounted) context.showErrorSnackBar(e);
    }
  }
}
