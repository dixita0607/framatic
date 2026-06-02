import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'sketch_icons.dart';
import 'sketch_painters.dart';
import 'sketch_theme.dart';
import 'sketch_background.dart';

typedef SketchRouteBuilder = Widget Function(BuildContext context);

PageRoute<T> sketchPageRoute<T>(
  SketchRouteBuilder builder, {
  RouteSettings? settings,
}) {
  return PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class SketchScreen extends StatelessWidget {
  final String? title;
  final Widget child;
  final Widget? floatingActionButton;
  final VoidCallback? onBack;

  const SketchScreen({
    super.key,
    this.title,
    required this.child,
    this.floatingActionButton,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SketchPageBackground(
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                if (title != null) SketchTopBar(title: title!, onBack: onBack),
                Expanded(child: child),
              ],
            ),
            if (floatingActionButton != null)
              Positioned(right: 18, bottom: 18, child: floatingActionButton!),
          ],
        ),
      ),
    );
  }
}

class SketchTopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const SketchTopBar({super.key, required this.title, this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      child: Row(
        children: [
          if (onBack != null) ...[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onBack,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: SketchIcon(
                    type: SketchIconType.back,
                    size: 18,
                    color: theme.ink,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              title,
              style: theme.titleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class SketchSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? fillColor;
  final Color? strokeColor;
  final Color? hachureColor;
  final SketchShape shape;
  final double radius;
  final int seed;
  final bool hachure;

  const SketchSurface({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.fillColor,
    this.strokeColor,
    this.hachureColor,
    this.shape = SketchShape.roundedRect,
    this.radius = 12,
    this.seed = 1,
    this.hachure = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    return CustomPaint(
      painter: SketchBorderPainter(
        theme: theme,
        strokeColor: strokeColor,
        fillColor: fillColor ?? theme.panel,
        hachureColor: hachureColor,
        shape: shape,
        radius: radius,
        seed: seed,
        hachure: hachure,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class SketchButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool danger;
  final bool filled;
  final bool primary;
  final Size minSize;
  final EdgeInsetsGeometry padding;

  const SketchButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.danger = false,
    this.filled = false,
    this.primary = false,
    this.minSize = const Size(64, 42),
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  });

  @override
  State<SketchButton> createState() => _SketchButtonState();
}

class _SketchButtonState extends State<SketchButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    final enabled = widget.onPressed != null;
    final stroke = !enabled
        ? theme.disabled
        : widget.danger
        ? theme.danger
        : widget.primary
        ? theme.primary
        : theme.ink;
    final fill = widget.filled
        ? widget.danger
              ? theme.danger
              : widget.primary
              ? theme.primary
              : theme.paper
        : theme.panel;
    final textColor = widget.filled
        ? widget.danger
              ? theme.primaryInk
              : widget.primary
              ? theme.primaryInk
              : theme.paperInk
        : stroke;

    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTapUp: enabled
            ? (_) {
                setState(() => _pressed = false);
                widget.onPressed?.call();
              }
            : null,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 80),
          child: Opacity(
            opacity: enabled ? 1 : 0.55,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: widget.minSize.width,
                minHeight: widget.minSize.height,
              ),
              child: SketchSurface(
                fillColor: fill,
                strokeColor: stroke,
                shape: SketchShape.roundedRect,
                radius: 4,
                seed: widget.label.hashCode,
                padding: widget.padding,
                child: Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: Text(
                    widget.label,
                    style: theme.bodyStyle.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SketchIconButton extends StatelessWidget {
  final SketchIconType icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final bool filled;
  final bool danger;
  final bool primary;
  final bool borderless;

  const SketchIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 48,
    this.filled = false,
    this.danger = false,
    this.primary = false,
    this.borderless = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    final enabled = onPressed != null;
    final color = danger
        ? theme.danger
        : primary
        ? theme.primary
        : theme.ink;
    final fill = filled
        ? primary
              ? theme.primary
              : theme.paper
        : theme.panel;
    final iconColor = filled
        ? primary
              ? theme.primaryInk
              : theme.paperInk
        : color;
    return Semantics(
      button: true,
      label: tooltip,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Opacity(
          opacity: enabled ? 1 : 0.55,
          child: SizedBox.square(
            dimension: size,
            child: borderless
                ? Center(
                    child: SketchIcon(
                      type: icon,
                      size: size * 0.52,
                      color: color,
                    ),
                  )
                : SketchSurface(
                    shape: SketchShape.circle,
                    fillColor: fill,
                    strokeColor: enabled ? color : theme.disabled,
                    seed: icon.index + 40,
                    child: Center(
                      child: SketchIcon(
                        type: icon,
                        size: size * 0.48,
                        color: iconColor,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class SketchProgress extends StatefulWidget {
  final double size;
  final Color? color;

  const SketchProgress({super.key, this.size = 28, this.color});

  @override
  State<SketchProgress> createState() => _SketchProgressState();
}

class _SketchProgressState extends State<SketchProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * math.pi * 2,
          child: CustomPaint(
            size: Size.square(widget.size),
            painter: _SketchProgressPainter(widget.color ?? theme.ink),
          ),
        );
      },
    );
  }
}

class _SketchProgressPainter extends CustomPainter {
  final Color color;

  const _SketchProgressPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Offset.zero & size,
      -math.pi / 2,
      math.pi * 1.45,
      false,
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.72, size.height * 0.12),
      Offset(size.width * 0.86, size.height * 0.2),
      paint,
    );
  }

  @override
  bool shouldRepaint(_SketchProgressPainter oldDelegate) =>
      oldDelegate.color != color;
}

class SketchSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final String? semanticLabel;

  const SketchSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    return Semantics(
      slider: true,
      label: semanticLabel,
      value: '${(value * 100).round()}%',
      increasedValue: '${((value + 0.1).clamp(0.0, 1.0) * 100).round()}%',
      decreasedValue: '${((value - 0.1).clamp(0.0, 1.0) * 100).round()}%',
      onIncrease: () => onChanged((value + 0.1).clamp(0.0, 1.0)),
      onDecrease: () => onChanged((value - 0.1).clamp(0.0, 1.0)),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) => _update(details.localPosition.dx, context),
        onHorizontalDragUpdate: (details) =>
            _update(details.localPosition.dx, context),
        child: SizedBox(
          height: 36,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return CustomPaint(
                size: Size(constraints.maxWidth, 36),
                painter: SketchSliderPainter(theme: theme, value: value),
              );
            },
          ),
        ),
      ),
    );
  }

  void _update(double dx, BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    final width = box?.size.width ?? 1;
    const inset = SketchSliderPainter.horizontalInset;
    final usableWidth = (width - inset * 2).clamp(1.0, double.infinity);
    onChanged(((dx - inset) / usableWidth).clamp(0.0, 1.0));
  }
}

class SketchChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final String? semanticLabel;

  const SketchChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel ?? label,
      child: GestureDetector(
        onTap: onSelected,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: SketchSurface(
            shape: SketchShape.roundedRect,
            radius: 5,
            fillColor: theme.panel,
            strokeColor: selected ? theme.accent : theme.mutedInk,
            hachure: selected,
            hachureColor: theme.accent.withValues(alpha: 0.26),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            seed: label.hashCode,
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Text(
                label,
                style: theme.labelStyle.copyWith(
                  color: selected ? theme.ink : theme.ink,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
        Text(widget.label, style: theme.labelStyle),
        const SizedBox(height: 6),
        SketchSurface(
          fillColor: theme.panelStrong,
          strokeColor: widget.errorText == null ? theme.mutedInk : theme.danger,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          seed: widget.label.hashCode,
          child: EditableText(
            controller: widget.controller,
            focusNode: _focusNode,
            style: theme.bodyStyle,
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
            child: Text(widget.hint!, style: theme.labelStyle),
          ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              widget.errorText!,
              style: theme.labelStyle.copyWith(color: theme.danger),
            ),
          ),
      ],
    );
  }
}

class SketchDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget> actions;

  const SketchDialog({
    super.key,
    required this.title,
    required this.child,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SketchSurface(
            fillColor: theme.panelStrong,
            hachure: true,
            padding: const EdgeInsets.all(20),
            seed: title.hashCode,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.titleStyle),
                const SizedBox(height: 18),
                child,
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      actions[i],
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<T?> showSketchDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return Navigator.of(context).push<T>(_SketchDialogRoute<T>(builder: builder));
}

class _SketchDialogRoute<T> extends PopupRoute<T> {
  final WidgetBuilder builder;

  _SketchDialogRoute({required this.builder});

  @override
  Color? get barrierColor => const Color(0x99000000);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 140);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return FadeTransition(
      opacity: animation,
      child: DefaultTextStyle(
        style: SketchTheme.of(context).bodyStyle,
        child: builder(context),
      ),
    );
  }
}

class SketchToast {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        final theme = SketchTheme.of(context);
        final fillColor = isError ? theme.danger : theme.primary;
        final contentColor = theme.primaryInk;
        return Positioned(
          left: 18,
          right: 18,
          bottom: 34,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: IgnorePointer(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420, minHeight: 40),
                child: SketchSurface(
                  fillColor: fillColor,
                  strokeColor: fillColor,
                  hachure: true,
                  hachureColor: contentColor.withValues(alpha: 0.12),
                  radius: 6,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  seed: message.hashCode,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SketchIcon(
                        type: isError
                            ? SketchIconType.error
                            : SketchIconType.check,
                        size: 18,
                        color: contentColor,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          message,
                          style: theme.bodyStyle.copyWith(
                            color: contentColor,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(entry);
    unawaited(Future<void>.delayed(duration, entry.remove));
  }
}
