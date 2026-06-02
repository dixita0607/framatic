import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/core/extensions/error_extension.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';

class ManageFrameDialog extends StatefulWidget {
  final Frame? frame;
  final List<Frame> existingFrames;
  final Function(Frame) onSave;

  const ManageFrameDialog({
    super.key,
    this.frame,
    this.existingFrames = const [],
    required this.onSave,
  });

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

    _nameController.addListener(_refreshPreview);
    _widthController.addListener(_refreshPreview);
    _heightController.addListener(_refreshPreview);
  }

  @override
  void dispose() {
    _nameController.removeListener(_refreshPreview);
    _widthController.removeListener(_refreshPreview);
    _heightController.removeListener(_refreshPreview);
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
              hint: 'e.g. Ultra Wide',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Frame name is required';
                }
                if (_hasDuplicateName(value.trim())) {
                  return 'Frame name already exists';
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
                      if (_hasDuplicateRatio()) {
                        return 'Ratio already exists';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _RatioPreview(
              width: int.tryParse(_widthController.text),
              height: int.tryParse(_heightController.text),
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

  void _refreshPreview() {
    if (mounted) {
      setState(() {});
    }
  }

  bool _hasDuplicateName(String name) {
    final currentId = widget.frame?.id;
    return widget.existingFrames.any(
      (frame) =>
          (currentId == null || frame.id != currentId) &&
          frame.title.trim().toLowerCase() == name.toLowerCase(),
    );
  }

  bool _hasDuplicateRatio() {
    final width = int.tryParse(_widthController.text);
    final height = int.tryParse(_heightController.text);
    if (width == null || height == null || width <= 0 || height <= 0) {
      return false;
    }

    final currentId = widget.frame?.id;
    final ratio = _normalizeRatio(width, height);
    return widget.existingFrames.any((frame) {
      if (currentId != null && frame.id == currentId) return false;
      return _normalizeRatio(frame.width, frame.height) == ratio;
    });
  }
}

class _RatioPreview extends StatelessWidget {
  final int? width;
  final int? height;

  const _RatioPreview({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    final hasValidRatio =
        width != null && height != null && width! > 0 && height! > 0;
    final ratioText = hasValidRatio ? '${width!}:${height!}' : null;
    final aspectRatio = hasValidRatio ? width! / height! : 1.0;

    return Semantics(
      label: hasValidRatio ? 'Preview ${width!} by ${height!}' : 'Preview',
      child: SketchSurface(
        fillColor: theme.panel,
        strokeColor: theme.mutedInk,
        padding: const EdgeInsets.all(12),
        seed: (width ?? 1) * 31 + (height ?? 1),
        child: Row(
          children: [
            SizedBox(
              width: 68,
              height: 48,
              child: Center(
                child: _PreviewBox(
                  aspectRatio: aspectRatio,
                  enabled: hasValidRatio,
                  theme: theme,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                hasValidRatio ? 'Preview $ratioText' : 'Preview',
                style: theme.labelStyle.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewBox extends StatelessWidget {
  final double aspectRatio;
  final bool enabled;
  final SketchThemeData theme;

  const _PreviewBox({
    required this.aspectRatio,
    required this.enabled,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    const maxWidth = 68.0;
    const maxHeight = 48.0;
    final widthConstrainedHeight = maxWidth / aspectRatio;
    final (width, height) = widthConstrainedHeight <= maxHeight
        ? (maxWidth, widthConstrainedHeight)
        : (maxHeight * aspectRatio, maxHeight);

    return SizedBox(
      width: width,
      height: height,
      child: SketchSurface(
        shape: SketchShape.rect,
        fillColor: enabled
            ? theme.paper.withValues(alpha: 0.22)
            : theme.panelStrong.withValues(alpha: 0.5),
        strokeColor: enabled ? theme.ink : theme.mutedInk,
        hachure: true,
        hachureColor: theme.mutedInk.withValues(alpha: 0.24),
        seed: aspectRatio.hashCode,
        child: const SizedBox.expand(),
      ),
    );
  }
}

(int, int) _normalizeRatio(int width, int height) {
  final divisor = width.gcd(height);
  return (width ~/ divisor, height ~/ divisor);
}
