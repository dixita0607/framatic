import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

/// Horizontal zoom slider with non-linear mapping for better visualization.
/// First half (0.0–0.5) maps to minZoom–2.0x; second half maps to 2.0x–maxZoom.
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

  bool _shouldTriggerHaptic(double newZoom) {
    final lastZoom = _lastHapticZoom ?? widget.currentZoom;
    if ((lastZoom - 1.0).abs() > 0.1 && (newZoom - 1.0).abs() <= 0.1) return true;
    if ((lastZoom - 2.0).abs() > 0.1 && (newZoom - 2.0).abs() <= 0.1) return true;
    return false;
  }

  double _zoomToSliderValue(double zoom) {
    final clampedZoom = zoom.clamp(widget.minZoom, widget.maxZoom);
    if (clampedZoom <= 2.0) {
      return ((clampedZoom - widget.minZoom) / (2.0 - widget.minZoom)) * 0.5;
    } else {
      return 0.5 + ((clampedZoom - 2.0) / (widget.maxZoom - 2.0)) * 0.5;
    }
  }

  double _sliderValueToZoom(double sliderValue) {
    final clampedValue = sliderValue.clamp(0.0, 1.0);
    if (clampedValue <= 0.5) {
      return widget.minZoom + (clampedValue / 0.5) * (2.0 - widget.minZoom);
    } else {
      return 2.0 + ((clampedValue - 0.5) / 0.5) * (widget.maxZoom - 2.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.maxZoom <= widget.minZoom) {
      final ink = SketchyTheme.of(context).inkColor;
      final paper = SketchyTheme.of(context).paperColor;
      return SketchyFrame(
        fill: SketchyFill.solid,
        fillColor: paper.withValues(alpha: 0.6),
        cornerRadius: 20,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: Text(
            '${widget.currentZoom.toStringAsFixed(1)}x',
            style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final sliderValue = _zoomToSliderValue(widget.currentZoom);
    final ink = SketchyTheme.of(context).inkColor;
    final paper = SketchyTheme.of(context).paperColor;

    return SketchyFrame(
      fill: SketchyFill.solid,
      fillColor: paper.withValues(alpha: 0.6),
      cornerRadius: 20,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Row(
          children: [
            // Zoom level indicator
            SketchyFrame(
              cornerRadius: 8,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  '${widget.currentZoom.toStringAsFixed(1)}x',
                  style: TextStyle(
                    color: ink,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SketchySlider(
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
            const SizedBox(width: 8),
            _buildQuickZoomButtons(ink),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickZoomButtons(Color ink) {
    final buttons = <Widget>[];

    if (widget.minZoom <= 0.6) buttons.add(_buildZoomButton(0.5, '½x', ink));
    buttons.add(_buildZoomButton(1.0, '1x', ink));
    if (widget.maxZoom >= 2.0) buttons.add(_buildZoomButton(2.0, '2x', ink));

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

  Widget _buildZoomButton(double zoom, String label, Color ink) {
    final isActive = (widget.currentZoom - zoom).abs() < 0.1;
    final isAvailable = zoom >= widget.minZoom && zoom <= widget.maxZoom;

    if (!isAvailable) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        if (_shouldTriggerHaptic(zoom)) {
          HapticFeedback.mediumImpact();
          _lastHapticZoom = zoom;
        }
        widget.onZoomChanged(zoom);
      },
      child: SketchyFrame(
        key: ValueKey('zoom-$zoom-$isActive'),
        shape: SketchyFrameShape.circle,
        width: 28,
        height: 28,
        fill: isActive ? SketchyFill.solid : SketchyFill.none,
        fillColor: isActive ? ink : null,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? SketchyTheme.of(context).paperColor : ink,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
