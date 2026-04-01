import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/core/utils/constants.dart';
import 'package:gal/gal.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class PhotoService {
  static String get albumName => AppConstants.galleryAlbumName;
  static int get borderThickness => AppConstants.frameBorderThickness.toInt();

  /// Process captured photo: crop to aspect ratio and add polaroid border.
  /// Returns the path to the processed temp file, or null on failure.
  Future<String?> processPhotoWithOverlay({
    required String imagePath,
    required Frame preset,
  }) async {
    try {
      // Read bytes on the main isolate (async I/O, non-blocking)
      final imageBytes = await File(imagePath).readAsBytes();

      // All CPU-bound work runs in a background isolate so the UI stays free.
      // The closure captures only sendable values (Uint8List, double, int).
      final resultBytes = await Isolate.run(
        () => _processImage(imageBytes, preset.aspectRatio, borderThickness),
      );

      if (resultBytes == null) {
        debugPrint('Failed to process image in isolate');
        return null;
      }

      // Write result back to a temp file on the main isolate (async I/O)
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imageFile = File('${tempDir.path}/frame_$timestamp.jpg');
      await imageFile.writeAsBytes(resultBytes);

      return imageFile.path;
    } catch (e) {
      debugPrint('Error processing photo with overlay: $e');
      return null;
    }
  }

  /// Save processed photo to gallery and delete the temp file.
  Future<bool> saveToGallery(String imagePath) async {
    try {
      await Gal.putImage(imagePath, album: albumName);
      await File(imagePath).delete();
      return true;
    } on GalException catch (e) {
      debugPrint('Error saving to gallery: ${e.type.message}');
      return false;
    }
  }

  /// Runs entirely inside the background isolate.
  /// Must be a static method — instance methods cannot be sent across isolates.
  static Uint8List? _processImage(
    Uint8List imageBytes,
    double aspectRatio,
    int border,
  ) {
    final originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) return null;

    final imageWidth = originalImage.width;
    final imageHeight = originalImage.height;
    final imageAspectRatio = imageWidth / imageHeight;

    int cropWidth, cropHeight;

    if (aspectRatio > imageAspectRatio) {
      // Frame is wider than image - fit to width, crop height
      cropWidth = imageWidth;
      cropHeight = (imageWidth / aspectRatio).round();
    } else {
      // Frame is taller than image - fit to height, crop width
      cropHeight = imageHeight;
      cropWidth = (imageHeight * aspectRatio).round();
    }

    final cropLeft = ((imageWidth - cropWidth) / 2).round();
    final cropTop = ((imageHeight - cropHeight) / 2).round();

    // Crop the image to the frame aspect ratio
    final croppedImage = img.copyCrop(
      originalImage,
      x: cropLeft,
      y: cropTop,
      width: cropWidth,
      height: cropHeight,
    );

    // Create final image with border
    final finalWidth = cropWidth + (border * 2);
    final finalHeight = cropHeight + (border * 2);

    final finalImage = img.Image(width: finalWidth, height: finalHeight);
    img.fill(finalImage, color: img.ColorRgba8(255, 255, 255, 255));
    img.compositeImage(finalImage, croppedImage, dstX: border, dstY: border);

    return Uint8List.fromList(img.encodeJpg(finalImage));
  }
}
