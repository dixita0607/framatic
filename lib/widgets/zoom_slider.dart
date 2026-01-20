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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom level indicator
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
          const SizedBox(height: 8),
          // Vertical slider
          SizedBox(
            height: 150,
            child: RotatedBox(
              quarterTurns: 3,
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
          ),
          const SizedBox(height: 4),
          // Quick zoom buttons
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
    buttons.add(_buildZoomButton(1.0, '1'));

    // Show 2x if within range
    if (maxZoom >= 2.0) {
      buttons.add(_buildZoomButton(2.0, '2'));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: buttons,
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
