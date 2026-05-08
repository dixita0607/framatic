import 'package:flutter/material.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

class CircularActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;

  const CircularActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final ink = SketchyTheme.of(context).inkColor;
    final primary = SketchyTheme.of(context).primaryColor;
    final isDisabled = onPressed == null;
    final iconColor = isPrimary ? const Color(0xFF000000) : ink;

    return GestureDetector(
      onTap: onPressed,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SketchyFrame(
              shape: SketchyFrameShape.circle,
              width: 64,
              height: 64,
              fill: isPrimary ? SketchyFill.solid : SketchyFill.none,
              fillColor: isPrimary ? primary : null,
              strokeColor: isPrimary ? primary : null,
              child: Center(
                child: isLoading
                    ? SketchyCircularProgressIndicator(
                        size: 24,
                        strokeWidth: 2,
                        color: iconColor,
                      )
                    : Icon(icon, color: iconColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
