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
  final List<String> existingTitles;

  const ManageFrameDialog({
    super.key,
    this.frame,
    required this.onSave,
    this.existingTitles = const [],
  });

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
    _widthController.addListener(_onRatioChanged);
    _heightController.addListener(_onRatioChanged);
  }

  void _onRatioChanged() => setState(() {});

  @override
  void dispose() {
    _widthController.removeListener(_onRatioChanged);
    _heightController.removeListener(_onRatioChanged);
    _nameController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Widget _buildAspectRatioPreview() {
    final w = int.tryParse(_widthController.text);
    final h = int.tryParse(_heightController.text);
    if (w == null || h == null || w <= 0 || h <= 0) return const SizedBox.shrink();

    const maxW = 120.0;
    const maxH = 80.0;
    final ratio = w / h;
    final double previewW;
    final double previewH;
    if (ratio >= maxW / maxH) {
      previewW = maxW;
      previewH = maxW / ratio;
    } else {
      previewH = maxH;
      previewW = maxH * ratio;
    }

    return Center(
      child: SketchyFrame(
        width: previewW,
        height: previewH,
        child: const SizedBox.shrink(),
      ),
    );
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
                        labelText: 'Ratio Width',
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
                        labelText: 'Ratio Height',
                        errorText: _heightError,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildAspectRatioPreview(),
              const SizedBox(height: 16),
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
    final name = _nameController.text.trim();
    final width = int.tryParse(_widthController.text);
    final height = int.tryParse(_heightController.text);

    String? nameError;
    if (name.isEmpty) {
      nameError = 'Frame name is required';
    } else if (name != widget.frame?.title &&
        widget.existingTitles.contains(name)) {
      nameError = 'A frame with this name already exists';
    }

    setState(() {
      _nameError = nameError;
      _widthError = (width == null || width <= 0) ? 'Must be > 0' : null;
      _heightError = (height == null || height <= 0) ? 'Must be > 0' : null;
    });

    if (_nameError != null || _widthError != null || _heightError != null) return;

    try {
      final frame = Frame(
        id: _isEditing ? widget.frame!.id : null,
        title: name,
        width: width!,
        height: height!,
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
