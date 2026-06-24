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

/// Fits inner content and a uniform border within the available bounds.
/// The border uses [longSideBorderRatio] and is capped by
/// [shortSideBorderCapRatio] for extreme aspect ratios.
({double width, double height, double borderWidth}) fitFramedAspectRatio({
  required double maxWidth,
  required double maxHeight,
  required double aspectRatio,
  required double longSideBorderRatio,
  required double shortSideBorderCapRatio,
  double bottomBorderMultiplier = 1,
}) {
  final borderRatioRelativeToWidth =
      calculateFrameBorderWidth(
        width: aspectRatio,
        height: 1,
        longSideRatio: longSideBorderRatio,
        shortSideCapRatio: shortSideBorderCapRatio,
      ) /
      aspectRatio;
  final widthLimitedByWidth = maxWidth / (1 + (2 * borderRatioRelativeToWidth));
  final widthLimitedByHeight =
      maxHeight /
      ((1 / aspectRatio) +
          (borderRatioRelativeToWidth * (1 + bottomBorderMultiplier)));
  final width = widthLimitedByWidth < widthLimitedByHeight
      ? widthLimitedByWidth
      : widthLimitedByHeight;

  return (
    width: width,
    height: width / aspectRatio,
    borderWidth: width * borderRatioRelativeToWidth,
  );
}

double calculateFrameBorderWidth({
  required double width,
  required double height,
  required double longSideRatio,
  required double shortSideCapRatio,
}) {
  final longestSide = width > height ? width : height;
  final shortestSide = width < height ? width : height;
  final proportionalWidth = longestSide * longSideRatio;
  final cappedWidth = shortestSide * shortSideCapRatio;
  return proportionalWidth < cappedWidth ? proportionalWidth : cappedWidth;
}
