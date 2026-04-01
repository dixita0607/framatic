import 'package:flutter/material.dart';

/// Circular action button with icon and label
/// Displays an icon in a circular container with a label below it
class CircularActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const CircularActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
}
