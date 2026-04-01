import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/core/utils/constants.dart';
import 'package:framatic/features/photo_preview/data/photo_repository.dart';
import 'package:gal/gal.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class PhotoService implements PhotoRepository {
  @override
  Future<String> processPhotoWithFrame({
    required String imagePath,
    required Frame frame,
  }) async {
    try {
      // Read bytes on the main isolate (async I/O, non-blocking)
      final imageBytes = await File(imagePath).readAsBytes();

      // All CPU-bound work runs in a background isolate so the UI stays free.
      // The closure captures only sendable values (Uint8List, double, int).
      final resultBytes = await Isolate.run(
        () => _processImage(
          imageBytes,
          frame.aspectRatio,
          AppConstants.frameBorderPercentage,
        ),
      );

      // Write result back to a temp file on the main isolate (async I/O)
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imageFile = File('${tempDir.path}/frame_$timestamp.jpg');
      await imageFile.writeAsBytes(resultBytes);

      return imageFile.path;
    } catch (e) {
      throw StateError('Error processing photo with overlay: $e');
    }
  }

  /// Save processed photo to gallery and delete the temp file.
  @override
  Future<bool> saveToGallery(String imagePath) async {
    try {
      await Gal.putImage(imagePath, album: AppConstants.galleryAlbumName);
      await File(imagePath).delete();
      return true;
    } on GalException catch (e) {
      debugPrint('Error saving to gallery: ${e.type.message}');
      return false;
    }
  }

  /// Runs entirely inside the background isolate.
  /// Must be a static method — instance methods cannot be sent across isolates.
  static Uint8List _processImage(
    Uint8List imageBytes,
    double aspectRatio,
    double borderPercentage,
  ) {
    final originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      throw StateError('Failed to decode image');
    }

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

    // Calculate border thickness as a percentage of the cropped frame width
    // This ensures the border scales proportionally on any device/image
    final border = (cropWidth * borderPercentage).round();

    // Create final image with border
    final finalWidth = cropWidth + (border * 2);
    final finalHeight = cropHeight + (border * 2);

    final finalImage = img.Image(width: finalWidth, height: finalHeight);
    img.fill(finalImage, color: img.ColorRgba8(255, 255, 255, 255));
    img.compositeImage(finalImage, croppedImage, dstX: border, dstY: border);

    return Uint8List.fromList(img.encodeJpg(finalImage));
  }
}
