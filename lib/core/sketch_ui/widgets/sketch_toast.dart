import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:framatic/core/sketch_ui/sketch_icons.dart';
import 'package:framatic/core/sketch_ui/sketch_theme.dart';
import 'package:framatic/core/sketch_ui/widgets/sketch_surface.dart';

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
                          style: theme.bodyText.copyWith(
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
