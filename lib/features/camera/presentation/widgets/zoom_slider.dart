import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';
import 'package:framatic/features/camera/domain/camera_constants.dart';

/// A horizontal zoom slider widget with proportional non-linear mapping.
///
/// Logarithmic mapping gives lower zoom levels more room on the slider while
/// supporting any positive zoom range reported by the selected camera.
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
  double? _previousZoom;

  /// Check if we should trigger haptic feedback when crossing zoom thresholds
  bool _shouldTriggerHaptic(double newZoom) {
    final previousZoom = _previousZoom ?? widget.currentZoom;
    _previousZoom = newZoom;

    return [defaultZoomLevel, 2.0].any(
      (threshold) =>
          (previousZoom < threshold && newZoom >= threshold) ||
          (previousZoom > threshold && newZoom <= threshold),
    );
  }

  /// Convert an actual zoom value to a proportional slider position (0.0-1.0).
  double _zoomToSliderValue(double zoom) {
    final clampedZoom = zoom.clamp(widget.minZoom, widget.maxZoom);
    final rangeRatio = widget.maxZoom / widget.minZoom;
    final zoomRatio = clampedZoom / widget.minZoom;

    return math.log(zoomRatio) / math.log(rangeRatio);
  }

  /// Convert a slider position (0.0-1.0) to an actual zoom value.
  double _sliderValueToZoom(double sliderValue) {
    final clampedValue = sliderValue.clamp(0.0, 1.0);

    return widget.minZoom *
        math.pow(widget.maxZoom / widget.minZoom, clampedValue);
  }

  @override
  Widget build(BuildContext context) {
    // Don't show slider if no zoom range available
    if (widget.maxZoom <= widget.minZoom) {
      return const SizedBox.shrink();
    }

    final sliderValue = _zoomToSliderValue(widget.currentZoom);
    final theme = SketchTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Zoom level indicator (left side)
          SketchSurface(
            padding: const .symmetric(horizontal: 6, vertical: 2),
            fillColor: theme.panelStrong,
            strokeColor: theme.mutedInk,
            shape: SketchShape.pill,
            seed: 621,
            child: Text(
              '${widget.currentZoom.toStringAsFixed(1)}x',
              style: theme.label.copyWith(
                color: theme.ink,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Horizontal slider (takes remaining space)
          Expanded(
            child: SketchSlider(
              semanticLabel: 'Zoom',
              value: sliderValue,
              onChanged: (newSliderValue) {
                final newZoom = _sliderValueToZoom(newSliderValue);
                if (_shouldTriggerHaptic(newZoom)) {
                  HapticFeedback.selectionClick();
                }
                widget.onZoomChanged(newZoom);
              },
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

    // Show 1x as the default quick zoom when it is supported.
    buttons.add(_buildZoomButton(defaultZoomLevel, '1x'));

    // Show 2x if within range
    if (widget.maxZoom >= 2.0) {
      buttons.add(_buildZoomButton(2.0, '2x'));
    }

    return Row(
      mainAxisSize: .min,
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

    final theme = SketchTheme.of(context);

    return Semantics(
      button: true,
      selected: isActive,
      label: 'Set zoom to $label',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_shouldTriggerHaptic(zoom)) {
            HapticFeedback.selectionClick();
          }
          widget.onZoomChanged(zoom);
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          child: Center(
            child: SizedBox(
              width: 38,
              height: 30,
              child: SketchSurface(
                shape: SketchShape.pill,
                fillColor: theme.panel,
                strokeColor: theme.ink,
                hachure: isActive,
                hachureColor: theme.ink.withValues(alpha: 0.18),
                seed: label.hashCode,
                child: Center(
                  child: Text(
                    label,
                    style: theme.label.copyWith(
                      color: theme.ink,
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
                    ),
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
