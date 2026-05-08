import 'package:flutter/widgets.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

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
    final primary = SketchyTheme.of(context).primaryColor;
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SketchyFrame(
          shape: SketchyFrameShape.circle,
          width: 88,
          height: 88,
          fill: SketchyFill.solid,
          fillColor: primary.withValues(alpha: 0.85),
          strokeColor: primary,
          child: widget.isCapturing
              ? const Center(
                  child: SketchyCircularProgressIndicator(
                    size: 24,
                    strokeWidth: 2.5,
                    color: Color(0xFFFFFFFF),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
