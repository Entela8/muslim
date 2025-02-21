// This is the class responsible for the notifications utils
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotification {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // show on an instant notification
  static Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload = 'item x',
  }) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'instant_notification_ch',
      'instant_notification_ch_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      12,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // show a repreated notification
  static Future<void> showRepeatingNotificationEachDay(
      {required String title,
      required String body,
      required TimeOfDay time,
      required int id}) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'repeated_notification_ch',
      'repeated_notification_ch_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    final today = DateTime.now();
    final scheduledDate = DateTime(
      today.year,
      today.month,
      today.day,
      time.hour,
      time.minute,
    );

    final targetTime = scheduledDate.isAfter(today)
        ? scheduledDate
        : scheduledDate.add(const Duration(days: 1));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(targetTime, tz.local),
      platformChannelSpecifics,
      payload: 'item x',
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // show on a scheduled notification
  static Future<void> scheduleANotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? sound = 'adhan',
  }) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'scheduled_notification_ch',
      'scheduled_notification_ch_name',
      sound: sound != null ? RawResourceAndroidNotificationSound(sound) : null,
      importance: Importance.max,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      payload: 'item x',
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancelAllNotifications() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    // Below will give you any unpresented/scheduled notifications
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for (var pendingRequest in pendingNotificationRequests) {
      flutterLocalNotificationsPlugin.cancel(pendingRequest.id);
    }
  }

  static Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
