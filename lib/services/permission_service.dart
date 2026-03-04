import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestCameraPermission() async {
    final status = Permission.camera
        .onPermanentlyDeniedCallback(() async => await openSettings())
        .request();
    return status.isGranted;
  }

  static Future<bool> get isCameraPermissionGranted async =>
      await Permission.camera.isGranted;

  static Future<bool> requestStoragePermission() async {
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        return await Gal.requestAccess();
      }
      return true;
    } catch (e) {
      debugPrint('Error requesting storage permission: $e');
      return false;
    }
  }

  static Future<bool> get isStoragePermissionGranted async {
    try {
      return await Gal.hasAccess();
    } catch (e) {
      debugPrint('Error checking storage permission: $e');
      return false;
    }
  }

  static Future<bool> openSettings() async => await openAppSettings();
}
