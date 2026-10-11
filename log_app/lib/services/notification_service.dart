import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/platform/platform_helper.dart';

// Android only
class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    // Android only: on web, do nothing quietly instead of crashing
    if (PlatformHelper.isWeb) return;

    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);

      await _notificationsPlugin.initialize(settings: initSettings);
      _isInitialized = true;
    } catch (e) {
      debugPrint('NotificationService init warning: $e');
    }
  }

  Future<void> showStockAlert({
    required int id,
    required String title,
    required String body,
  }) async {
    // Android only: on web, do nothing quietly instead of crashing
    if (PlatformHelper.isWeb || !_isInitialized) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        'stock_alerts',
        'Stock Alerts',
        channelDescription: 'Notifications for low stock items',
        importance: Importance.high,
        priority: Priority.high,
      );
      const details = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
      );
    } catch (e) {
      debugPrint('NotificationService show error: $e');
    }
  }
}
