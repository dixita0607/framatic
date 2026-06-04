import 'package:flutter/widgets.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';

class CaptureButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isCapturing;

  const CaptureButton({
    super.key,
    required this.onPressed,
    this.isCapturing = false,
  });

  @override
  State<CaptureButton> createState() => _CaptureButtonState();
}

class _CaptureButtonState extends State<CaptureButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    final enabled = widget.onPressed != null && !widget.isCapturing;
    return Semantics(
      button: true,
      label: 'Capture photo',
      enabled: enabled,
      value: widget.isCapturing ? 'Capturing' : null,
      child: GestureDetector(
        onTapDown: enabled ? (_) => _scaleController.forward() : null,
        onTapUp: enabled
            ? (_) {
                _scaleController.reverse();
                widget.onPressed?.call();
              }
            : null,
        onTapCancel: enabled ? () => _scaleController.reverse() : null,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SizedBox.square(
            dimension: 88,
            child: SketchSurface(
              shape: SketchShape.circle,
              fillColor: theme.ink.withValues(alpha: 0.18),
              strokeColor: theme.ink,
              seed: 909,
              child: Center(
                child: widget.isCapturing
                    ? SketchProgress(size: 28, color: theme.ink)
                    : SizedBox.square(
                        dimension: 56,
                        child: SketchSurface(
                          shape: SketchShape.circle,
                          fillColor: theme.paper,
                          strokeColor: theme.ink,
                          seed: 910,
                          child: const SizedBox.shrink(),
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
