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

  static Future<bool> openSettings() async => await openAppSettings();
}
