import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:muslim_alim/services/local_notification_service.dart';

class PushNotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Request permission for notifications
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Set presentation options for iOS foreground notifications
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Handle incoming messages when the app is in the foreground
      FirebaseMessaging.onMessage.listen(_handleMessage);

      // Handle incoming messages when the app is in the background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

      // Handle messages when the app is terminated
      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleMessage(initialMessage);
      }

      // Check and subscribe to all topic if not already subscribed
      await _fcm.subscribeToTopic('all');
    }
  }

  static void _handleMessage(RemoteMessage message) {
    if (message.notification != null) {
      LocalNotification.showInstantNotification(
        title: message.notification?.title ?? 'New Message',
        body: message.notification?.body ?? '',
        payload: message.data.toString(),
      );
    }
  }
}
