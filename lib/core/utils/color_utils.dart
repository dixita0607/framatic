import 'package:flutter/widgets.dart';

/// Returns black or white — whichever contrasts better against [background].
/// Uses the WCAG relative luminance threshold (0.179).
Color onColor(Color background) =>
    background.computeLuminance() > 0.179
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF);
