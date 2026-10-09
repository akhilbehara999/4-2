import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (kIsWeb) return;
    if (_isInitialized) return;

    try {
      await Permission.notification.request();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);

      await _notifications.initialize(settings: initSettings);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Notification init error: $e');
    }
  }

  Future<void> showLowStockNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    if (!_isInitialized) await init();

    try {
      const androidDetails = AndroidNotificationDetails(
        'low_stock_channel',
        'Low Stock Alerts',
        channelDescription: 'Notifications when inventory items are running low',
        importance: Importance.high,
        priority: Priority.high,
      );
      const details = NotificationDetails(android: androidDetails);
      await _notifications.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
      );
    } catch (e) {
      debugPrint('Show notification error: $e');
    }
  }
}
