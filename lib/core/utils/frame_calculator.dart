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
