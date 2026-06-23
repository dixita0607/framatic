import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:framatic/core/sketch_ui/sketch_theme.dart';
import 'package:framatic/core/sketch_ui/widgets/sketch_surface.dart';

class SketchFormInput extends FormField<String> {
  SketchFormInput({
    super.key,
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    super.validator,
  }) : super(
         initialValue: controller.text,
         builder: (state) {
           return _SketchEditableText(
             controller: controller,
             label: label,
             hint: hint,
             keyboardType: keyboardType,
             inputFormatters: inputFormatters,
             errorText: state.errorText,
             onChanged: state.didChange,
           );
         },
       );
}

class _SketchEditableText extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final ValueChanged<String> onChanged;

  const _SketchEditableText({
    required this.controller,
    required this.label,
    required this.hint,
    required this.keyboardType,
    required this.inputFormatters,
    required this.errorText,
    required this.onChanged,
  });

  @override
  State<_SketchEditableText> createState() => _SketchEditableTextState();
}

class _SketchEditableTextState extends State<_SketchEditableText> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: theme.label),
        const SizedBox(height: 6),
        SketchSurface(
          fillColor: theme.panelStrong,
          strokeColor: widget.errorText == null ? theme.mutedInk : theme.danger,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          seed: widget.label.hashCode,
          child: EditableText(
            controller: widget.controller,
            focusNode: _focusNode,
            style: theme.bodyText,
            cursorColor: theme.accent,
            backgroundCursorColor: theme.disabled,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            maxLines: 1,
            selectionColor: theme.accent.withValues(alpha: 0.35),
          ),
        ),
        if (widget.hint != null && widget.controller.text.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(widget.hint!, style: theme.label),
          ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              widget.errorText!,
              style: theme.label.copyWith(color: theme.danger),
            ),
          ),
      ],
    );
  }
}
