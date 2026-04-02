import 'dart:ui';

import 'package:framatic/core/utils/constants.dart';

/// Fits a rectangle of [aspectRatio] within [maxWidth] × [maxHeight] bounds.
///
/// Pure math — no Flutter dependency. Safe to use in isolates.
({double width, double height}) fitToAspectRatio({
  required double maxWidth,
  required double maxHeight,
  required double aspectRatio,
}) {
  double width = maxWidth;
  double height = width / aspectRatio;

  if (height > maxHeight) {
    height = maxHeight;
    width = height * aspectRatio;
  }

  return (width: width, height: height);
}

/// Calculates the inner frame dimensions (excluding border) for screen layout.
///
/// Applies padding ([AppConstants.maxFramePadding]) and accounts for border
/// ([AppConstants.frameBorderPercentage]) so that frame + border together
/// fit within the padded bounds.
Size calculateFrameSize({
  required double maxWidth,
  required double maxHeight,
  required double aspectRatio,
}) {
  final borderFactor = 1 + (2 * AppConstants.frameBorderPercentage);
  final availableWidth = maxWidth * AppConstants.maxFramePadding / borderFactor;
  final availableHeight =
      maxHeight * AppConstants.maxFramePadding / borderFactor;

  final result = fitToAspectRatio(
    maxWidth: availableWidth,
    maxHeight: availableHeight,
    aspectRatio: aspectRatio,
  );

  return Size(result.width, result.height);
}
