import 'package:muslim_alim/services/prayer_notification_service.dart';
import 'package:muslim_alim/utils/prayer_times/get_prayer_times.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> handleEnablePrayerNotification(String message) async {
  for (final prayer in Prayer.values) {
    final prayerLower = prayer.displayName.toLowerCase();

    if (message == 'enable${prayer.displayName}Notification') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("${prayerLower}Enabled", true);
      await schedulePrayerNotification(
        prayer: prayer,
        scheduledDate: getPrayerTime(prayer, await getPrayerTimes()),
      );
    }
  }
}
