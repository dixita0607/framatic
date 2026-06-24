import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:framatic/core/models/frame.dart';
import 'package:framatic/core/utils/constants.dart';
import 'package:framatic/core/utils/frame_calculator.dart';
import 'package:framatic/features/photo_preview/data/photo_repository.dart';
import 'package:framatic/features/photo_preview/domain/photo_error.dart';
import 'package:gal/gal.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class PhotoService implements PhotoRepository {
  @override
  Future<String> processPhotoWithFrame({
    required String imagePath,
    required Frame frame,
  }) async {
    final sourceFile = File(imagePath);
    try {
      // Read bytes on the main isolate (async I/O, non-blocking)
      final imageBytes = await sourceFile.readAsBytes();

      // All CPU-bound work runs in a background isolate so the UI stays free.
      // The closure captures only sendable values (Uint8List, double, int).
      final resultBytes = await Isolate.run(
        () => _processImage(imageBytes, frame.aspectRatio, frame.paperRatio),
      );

      // Write result back to a temp file on the main isolate (async I/O)
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imageFile = File('${tempDir.path}/frame_$timestamp.jpg');
      await imageFile.writeAsBytes(resultBytes);

      return imageFile.path;
    } catch (e) {
      throw ProcessPhotoError(
        'Error processing photo with overlay: $e',
        userMessage: 'Failed to process photo.',
        cause: e,
      );
    } finally {
      sourceFile.delete().ignore();
    }
  }

  /// Save processed photo to gallery.
  @override
  Future<void> saveToGallery(String imagePath) async {
    try {
      await Gal.putImage(imagePath, album: AppConstants.appName);
    } on GalException catch (e) {
      throw SavePhotoError(
        'Error saving to gallery: ${e.type.message}',
        userMessage: 'Failed to save photo to gallery.',
        cause: e,
      );
    }
  }

  static Future<void> cleanupTempFiles() async {
    final tempDir = await getTemporaryDirectory();
    tempDir
        .listSync()
        .whereType<File>()
        .where((f) => f.uri.pathSegments.last.startsWith('frame_'))
        .forEach((f) => f.delete().ignore());
  }

  /// Runs entirely inside the background isolate.
  /// Must be a static method — instance methods cannot be sent across isolates.
  static Uint8List _processImage(
    Uint8List imageBytes,
    double aspectRatio,
    String ratioLabel,
  ) {
    final originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      throw DecodePhotoError(
        'Failed to decode image',
        userMessage: 'Failed to process photo.',
      );
    }

    final innerImageSize = fitToAspectRatio(
      maxWidth: originalImage.width.toDouble(),
      maxHeight: originalImage.height.toDouble(),
      aspectRatio: aspectRatio,
    );
    final cropWidth = innerImageSize.width.round();
    final cropHeight = innerImageSize.height.round();
    final cropLeft = ((originalImage.width - cropWidth) / 2).round();
    final cropTop = ((originalImage.height - cropHeight) / 2).round();

    final croppedImage = img.copyCrop(
      originalImage,
      x: cropLeft,
      y: cropTop,
      width: cropWidth,
      height: cropHeight,
    );

    final borderWidth = calculateFrameBorderWidth(
      width: croppedImage.width.toDouble(),
      height: croppedImage.height.toDouble(),
      longSideRatio: AppConstants.frameBorderRatio,
      shortSideCapRatio: AppConstants.maxFrameBorderShortSideRatio,
    ).round();
    final bottomBorderWidth = math.max(
      borderWidth,
      (borderWidth * AppConstants.frameBottomBorderMultiplier).round(),
    );

    final imageWithBorder = img.Image(
      width: croppedImage.width + (2 * borderWidth),
      height: croppedImage.height + borderWidth + bottomBorderWidth,
      numChannels: 4,
    );

    img.fill(
      imageWithBorder,
      color: img.ColorRgba8(
        AppConstants.paperRed,
        AppConstants.paperGreen,
        AppConstants.paperBlue,
        255,
      ),
    );

    img.compositeImage(
      imageWithBorder,
      croppedImage,
      dstX: borderWidth,
      dstY: borderWidth,
    );
    _finishPaperFrame(
      imageWithBorder,
      photoWidth: croppedImage.width,
      photoHeight: croppedImage.height,
      borderWidth: borderWidth,
      bottomBorderWidth: bottomBorderWidth,
      ratioLabel: ratioLabel,
    );

    return Uint8List.fromList(img.encodeJpg(imageWithBorder));
  }

  static void _finishPaperFrame(
    img.Image image, {
    required int photoWidth,
    required int photoHeight,
    required int borderWidth,
    required int bottomBorderWidth,
    required String ratioLabel,
  }) {
    final photoLeft = borderWidth;
    final photoTop = borderWidth;
    final photoRight = photoLeft + photoWidth - 1;
    final photoBottom = photoTop + photoHeight - 1;

    _drawPaperGrain(
      image,
      photoLeft: photoLeft,
      photoTop: photoTop,
      photoRight: photoRight,
      photoBottom: photoBottom,
    );
    _drawInnerShadow(
      image,
      left: photoLeft,
      top: photoTop,
      right: photoRight,
      bottom: photoBottom,
      borderWidth: borderWidth,
    );
    _drawRoughRect(
      image,
      left: photoLeft,
      top: photoTop,
      right: photoRight,
      bottom: photoBottom,
      amplitude: math.max(1, (borderWidth * 0.025).round()),
      color: img.ColorRgba8(87, 81, 73, 38),
      thickness: math.max(1, (borderWidth * 0.018).round()),
      seed: 47,
    );
    _drawRoughRect(
      image,
      left: 1,
      top: 1,
      right: image.width - 2,
      bottom: image.height - 2,
      amplitude: math.max(1, (borderWidth * 0.018).round()),
      color: img.ColorRgba8(87, 81, 73, 28),
      thickness: math.max(1, (borderWidth * 0.012).round()),
      seed: 19,
    );

    final markHeight = math.max(2, (bottomBorderWidth * 0.40).round());
    final labelImage = _renderRatioLabel(ratioLabel, markHeight);
    final markX = math.max(
      photoLeft,
      ((image.width - labelImage.width) / 2).round(),
    );
    final markY =
        photoBottom + 1 + ((bottomBorderWidth - labelImage.height) / 2).round();
    img.compositeImage(image, labelImage, dstX: markX, dstY: markY);
  }

  static void _drawPaperGrain(
    img.Image image, {
    required int photoLeft,
    required int photoTop,
    required int photoRight,
    required int photoBottom,
  }) {
    final random = math.Random(3901);
    final borderArea =
        (image.width * image.height) -
        ((photoRight - photoLeft + 1) * (photoBottom - photoTop + 1));
    final grainCount = (borderArea / 3200).round().clamp(70, 900);
    var drawn = 0;
    var attempts = 0;
    while (drawn < grainCount && attempts < grainCount * 8) {
      attempts++;
      final x = random.nextInt(image.width);
      final y = random.nextInt(image.height);
      final isPhoto =
          x >= photoLeft &&
          x <= photoRight &&
          y >= photoTop &&
          y <= photoBottom;
      if (isPhoto) continue;
      final warmth = random.nextBool() ? 78 : 126;
      img.drawLine(
        image,
        x1: x,
        y1: y,
        x2: math.min(image.width - 1, x + 1 + random.nextInt(3)),
        y2: y,
        color: img.ColorRgba8(warmth, warmth - 5, warmth - 12, 12),
      );
      drawn++;
    }
  }

  static void _drawInnerShadow(
    img.Image image, {
    required int left,
    required int top,
    required int right,
    required int bottom,
    required int borderWidth,
  }) {
    final depth = math.max(1, math.min(10, (borderWidth * 0.14).round()));
    for (var inset = 0; inset < depth; inset++) {
      final alpha = (32 * (1 - (inset / depth))).round();
      final color = img.ColorRgba8(0, 0, 0, alpha);
      img.drawLine(
        image,
        x1: left + inset,
        y1: top + inset,
        x2: right - inset,
        y2: top + inset,
        color: color,
      );
      img.drawLine(
        image,
        x1: left + inset,
        y1: bottom - inset,
        x2: right - inset,
        y2: bottom - inset,
        color: color,
      );
      img.drawLine(
        image,
        x1: left + inset,
        y1: top + inset,
        x2: left + inset,
        y2: bottom - inset,
        color: color,
      );
      img.drawLine(
        image,
        x1: right - inset,
        y1: top + inset,
        x2: right - inset,
        y2: bottom - inset,
        color: color,
      );
    }
  }

  static void _drawRoughRect(
    img.Image image, {
    required int left,
    required int top,
    required int right,
    required int bottom,
    required int amplitude,
    required img.Color color,
    required int thickness,
    required int seed,
  }) {
    const segments = 28;
    final points = <(int, int)>[];
    var index = 0;

    int wave() {
      final value =
          (math.sin((index + seed) * 1.73) * 0.62) +
          (math.sin((index + seed) * 0.59) * 0.38);
      index++;
      return (value * amplitude).round();
    }

    for (var i = 0; i <= segments; i++) {
      points.add((
        left + ((right - left) * i / segments).round(),
        top + wave(),
      ));
    }
    for (var i = 1; i <= segments; i++) {
      points.add((
        right + wave(),
        top + ((bottom - top) * i / segments).round(),
      ));
    }
    for (var i = 1; i <= segments; i++) {
      points.add((
        right - ((right - left) * i / segments).round(),
        bottom + wave(),
      ));
    }
    for (var i = 1; i <= segments; i++) {
      points.add((
        left + wave(),
        bottom - ((bottom - top) * i / segments).round(),
      ));
    }
    points.add(points.first);

    for (var i = 1; i < points.length; i++) {
      img.drawLine(
        image,
        x1: points[i - 1].$1,
        y1: points[i - 1].$2,
        x2: points[i].$1,
        y2: points[i].$2,
        color: color,
        thickness: thickness,
      );
    }
  }

  static img.Image _renderRatioLabel(String label, int targetHeight) {
    final font = img.arial48;
    final sourceWidth = label
        .split('')
        .fold<int>(
          0,
          (width, character) => width + font.characterXAdvance(character),
        );
    final source = img.Image(
      width: math.max(1, sourceWidth),
      height: font.lineHeight,
      numChannels: 4,
    );
    img.fill(source, color: img.ColorRgba8(0, 0, 0, 0));
    img.drawString(
      source,
      label,
      font: font,
      x: 0,
      y: 0,
      color: img.ColorRgba8(0, 0, 0, 255),
    );
    return img.copyResize(
      source,
      height: targetHeight,
      interpolation: img.Interpolation.linear,
    );
  }
}
