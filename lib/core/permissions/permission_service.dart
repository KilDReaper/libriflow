import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      openAppSettings();
    }

    return false;
  }
}
