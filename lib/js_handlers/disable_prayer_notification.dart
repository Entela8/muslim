import 'package:muslim_alim/services/local_notification_service.dart';
import 'package:muslim_alim/services/prayer_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> handleDisablePrayerNotification(String message) async {
  for (final prayer in Prayer.values) {
    final prayerLower = prayer.displayName.toLowerCase();

    if (message == 'disable${prayer.displayName}Notification') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("${prayerLower}Enabled", false);
      await LocalNotification.cancelNotification(prayer.notificationId);
    }
  }
}
