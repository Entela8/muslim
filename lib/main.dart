import 'package:flutter/material.dart';
import 'package:muslim_alim/screens/webview_screen.dart';
import 'package:muslim_alim/services/local_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_core/firebase_core.dart';
import 'package:muslim_alim/services/push_notification_service.dart';
import 'firebase_options.dart';

void main() async {
  // initialization
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // Update widget location
  prefs.setBool('shouldUpdateWidgetLocation', true);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  tz.initializeTimeZones();

  await LocalNotification.initialize();
  await PushNotificationService.initialize();

  // Schedule prayer notifications
  prefs.setBool('shouldSchedulePrayerNotifications', true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const WebViewScreen(),
    );
  }
}
