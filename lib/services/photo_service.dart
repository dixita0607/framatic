import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:framatic/models/frame.dart';
import 'package:framatic/utils/constants.dart';
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
      // Read the captured image
      final imageBytes = await File(imagePath).readAsBytes();
      final originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        debugPrint('Failed to decode image');
        return null;
      }

      // Calculate crop dimensions based on aspect ratio
      final imageWidth = originalImage.width;
      final imageHeight = originalImage.height;
      final imageAspectRatio = imageWidth / imageHeight;

      int cropWidth, cropHeight, cropLeft, cropTop;

      if (preset.aspectRatio > imageAspectRatio) {
        // Frame is wider than image - fit to width, crop height
        cropWidth = imageWidth;
        cropHeight = (imageWidth / preset.aspectRatio).round();
      } else {
        // Frame is taller than image - fit to height, crop width
        cropHeight = imageHeight;
        cropWidth = (imageHeight * preset.aspectRatio).round();
      }

      // Center the crop
      cropLeft = ((imageWidth - cropWidth) / 2).round();
      cropTop = ((imageHeight - cropHeight) / 2).round();

      // Crop the image to the frame aspect ratio
      final croppedImage = img.copyCrop(
        originalImage,
        x: cropLeft,
        y: cropTop,
        width: cropWidth,
        height: cropHeight,
      );

      // Create final image with border
      final finalWidth = cropWidth + (borderThickness * 2);
      final finalHeight = cropHeight + (borderThickness * 2);

      final finalImage = img.Image(width: finalWidth, height: finalHeight);

      // Fill with white (border color)
      final borderColor = img.ColorRgba8(255, 255, 255, 255);
      img.fill(finalImage, color: borderColor);

      // Composite the cropped image onto the center
      img.compositeImage(
        finalImage,
        croppedImage,
        dstX: borderThickness,
        dstY: borderThickness,
      );

      // Write processed image to a temp file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imageFile = File('${tempDir.path}/frame_$timestamp.jpg');
      await imageFile.writeAsBytes(
        Uint8List.fromList(img.encodeJpg(finalImage)),
      );

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
}
