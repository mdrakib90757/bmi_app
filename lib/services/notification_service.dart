// lib/services/notification_service.dart
// Daily BMI Reminder using flutter_local_notifications

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  // Schedule daily reminder at 9:00 AM
  static Future<void> scheduleDailyReminder() async {
    await _plugin.zonedSchedule(
      0,
      '💪 BMI Check Reminder',
      'Track your progress! Open BMI Calculator and check your BMI today.',
      _nextInstanceOf9AM(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'bmi_daily_reminder',
          'Daily BMI Reminder',
          channelDescription: 'Reminds you to check your BMI daily',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }

  // Cancel daily reminder
  static Future<void> cancelDailyReminder() async {
    await _plugin.cancel(0);
  }

  // Cancel all notifications
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static tz.TZDateTime _nextInstanceOf9AM() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      9, // 9 AM
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
