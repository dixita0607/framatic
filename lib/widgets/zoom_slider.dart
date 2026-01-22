import 'package:flutter/material.dart';

/// A vertical zoom slider widget with zoom level indicator
class ZoomSlider extends StatelessWidget {
  final double minZoom;
  final double maxZoom;
  final double currentZoom;
  final ValueChanged<double> onZoomChanged;

  const ZoomSlider({
    super.key,
    required this.minZoom,
    required this.maxZoom,
    required this.currentZoom,
    required this.onZoomChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show slider if no zoom range available
    if (maxZoom <= minZoom) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom level indicator (left side)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${currentZoom.toStringAsFixed(1)}x',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Horizontal slider
          SizedBox(
            width: 100,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                thumbColor: Colors.white,
                overlayColor: Colors.white.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: currentZoom,
                min: minZoom,
                max: maxZoom,
                onChanged: onZoomChanged,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Quick zoom buttons (right side)
          _buildQuickZoomButtons(),
        ],
      ),
    );
  }

  Widget _buildQuickZoomButtons() {
    final buttons = <Widget>[];

    // Add 0.5x button if device supports ultra-wide
    if (minZoom <= 0.6) {
      buttons.add(_buildZoomButton(0.5, '0.5'));
    }

    // Always show 1x
    buttons.add(_buildZoomButton(1.0, '1x'));

    // Show 2x if within range
    if (maxZoom >= 2.0) {
      buttons.add(_buildZoomButton(2.0, '2x'));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < buttons.length; i++) ...[
          buttons[i],
          if (i < buttons.length - 1) const SizedBox(width: 4),
        ],
      ],
    );
  }

  Widget _buildZoomButton(double zoom, String label) {
    final isActive = (currentZoom - zoom).abs() < 0.1;
    final isAvailable = zoom >= minZoom && zoom <= maxZoom;

    if (!isAvailable) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => onZoomChanged(zoom),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? Colors.white
              : Colors.white.withValues(alpha: 0.2),
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.black : Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
