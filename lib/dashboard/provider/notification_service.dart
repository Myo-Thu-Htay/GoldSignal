import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
 static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidSetting =
        AndroidInitializationSettings('@drawable/ic_notification');

    const InitializationSettings settings =
        InitializationSettings(
      android: androidSetting,
    );

    await _notifications.initialize(settings: settings);
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'signal_engine_channel',
      'Gold Signal',
      icon: '@drawable/ic_notification',
      channelDescription: 'Notifications for XAUUSD Signal',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidDetails);

    await _notifications.show(
      id: 0, // Notification ID
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics, 
      
    );
  }
}