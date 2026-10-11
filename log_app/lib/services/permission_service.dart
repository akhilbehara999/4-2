import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/platform/platform_helper.dart';

// Android only
class PermissionService {
  static Future<bool> requestMicrophonePermission() async {
    // Android only: on non-Android platforms (web/test/desktop), succeed quietly
    if (!PlatformHelper.isAndroid) return true;

    try {
      final status = await Permission.microphone.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('PermissionService microphone request notice: $e');
      return true;
    }
  }

  static Future<bool> requestNotificationPermission() async {
    // Android only: on non-Android platforms, succeed quietly
    if (!PlatformHelper.isAndroid) return true;

    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('PermissionService notification request notice: $e');
      return true;
    }
  }
}
