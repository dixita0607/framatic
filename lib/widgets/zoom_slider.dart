import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A horizontal zoom slider widget with non-linear mapping for better visualization
///
/// The slider uses non-linear mapping:
/// - First half (0.0-0.5): Maps to 0.5x - 2.0x zoom range
/// - Second half (0.5-1.0): Maps to 2.0x - maxZoom range
///
/// This provides better visual distinction for common zoom levels (0.5x, 1x, 2x)
/// while still allowing access to the full zoom range.
class ZoomSlider extends StatefulWidget {
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
  State<ZoomSlider> createState() => _ZoomSliderState();
}

class _ZoomSliderState extends State<ZoomSlider> {
  double? _lastHapticZoom;

  /// Check if we should trigger haptic feedback when crossing zoom thresholds
  bool _shouldTriggerHaptic(double newZoom) {
    final lastZoom = _lastHapticZoom ?? widget.currentZoom;

    // Check if crossing 1.0x threshold
    if ((lastZoom - 1.0).abs() > 0.1 && (newZoom - 1.0).abs() <= 0.1) {
      return true;
    }

    // Check if crossing 2.0x threshold
    if ((lastZoom - 2.0).abs() > 0.1 && (newZoom - 2.0).abs() <= 0.1) {
      return true;
    }

    return false;
  }

  /// Convert actual zoom value to slider position (0.0-1.0)
  /// Uses non-linear mapping for better visualization
  double _zoomToSliderValue(double zoom) {
    // Normalize zoom to effective range [minZoom, maxZoom]
    final clampedZoom = zoom.clamp(widget.minZoom, widget.maxZoom);

    // Non-linear mapping:
    // First half: minZoom to 2.0x → slider 0.0 to 0.5
    // Second half: 2.0x to maxZoom → slider 0.5 to 1.0
    if (clampedZoom <= 2.0) {
      // First half: map [minZoom, 2.0] to [0.0, 0.5]
      return ((clampedZoom - widget.minZoom) / (2.0 - widget.minZoom)) * 0.5;
    } else {
      // Second half: map [2.0, maxZoom] to [0.5, 1.0]
      return 0.5 + ((clampedZoom - 2.0) / (widget.maxZoom - 2.0)) * 0.5;
    }
  }

  /// Convert slider position (0.0-1.0) to actual zoom value
  /// Uses non-linear mapping for better visualization
  double _sliderValueToZoom(double sliderValue) {
    final clampedValue = sliderValue.clamp(0.0, 1.0);

    // Non-linear mapping (inverse):
    // Slider 0.0 to 0.5 → zoom minZoom to 2.0x
    // Slider 0.5 to 1.0 → zoom 2.0x to maxZoom
    if (clampedValue <= 0.5) {
      // First half: map [0.0, 0.5] to [minZoom, 2.0]
      return widget.minZoom + (clampedValue / 0.5) * (2.0 - widget.minZoom);
    } else {
      // Second half: map [0.5, 1.0] to [2.0, maxZoom]
      return 2.0 + ((clampedValue - 0.5) / 0.5) * (widget.maxZoom - 2.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show slider if no zoom range available
    if (widget.maxZoom <= widget.minZoom) {
      return const SizedBox.shrink();
    }

    final sliderValue = _zoomToSliderValue(widget.currentZoom);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Zoom level indicator (left side)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${widget.currentZoom.toStringAsFixed(1)}x',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Horizontal slider (takes remaining space)
          Expanded(
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
                value: sliderValue,
                min: 0.0,
                max: 1.0,
                onChanged: (newSliderValue) {
                  final newZoom = _sliderValueToZoom(newSliderValue);
                  if (_shouldTriggerHaptic(newZoom)) {
                    HapticFeedback.mediumImpact();
                    _lastHapticZoom = newZoom;
                  }
                  widget.onZoomChanged(newZoom);
                },
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
    if (widget.minZoom <= 0.6) {
      buttons.add(_buildZoomButton(0.5, '0.5'));
    }

    // Always show 1x
    buttons.add(_buildZoomButton(1.0, '1x'));

    // Show 2x if within range
    if (widget.maxZoom >= 2.0) {
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
    final isActive = (widget.currentZoom - zoom).abs() < 0.1;
    final isAvailable = zoom >= widget.minZoom && zoom <= widget.maxZoom;

    if (!isAvailable) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        if (_shouldTriggerHaptic(zoom)) {
          HapticFeedback.mediumImpact();
          _lastHapticZoom = zoom;
        }
        widget.onZoomChanged(zoom);
      },
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
