import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:framatic/core/services/permission_service.dart';
import 'package:framatic/core/utils/constants.dart';
import 'package:framatic/features/photo_preview/data/photo_repository.dart';

class PhotoPreviewProvider extends ChangeNotifier {
  final PhotoRepository _photoRepository;

  bool _isSaving = false;

  PhotoPreviewProvider(this._photoRepository);

  bool get isSaving => _isSaving;

  Future<void> savePhoto(String imagePath) async {
    _isSaving = true;
    notifyListeners();

    try {
      final hasPermission = await PermissionService.requestStoragePermission();
      if (!hasPermission) {
        throw StateError('Storage permission required to save photos');
      }

      await _photoRepository.saveToGallery(imagePath);
    } catch (e) {
      debugPrint('Error saving photo: $e');
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void retakePhoto(String imagePath) {
    File(imagePath).delete().ignore();
  }

  String get successMessage =>
      'Photo saved to ${AppConstants.galleryAlbumName} album';
}
