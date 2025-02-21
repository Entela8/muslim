import 'package:flutter/material.dart';
import 'package:muslim_alim/models/PrayerTimes.dart';
import 'package:muslim_alim/services/local_notification_service.dart';
import 'package:muslim_alim/utils/prayer_times/get_prayer_times.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Prayer {
  fajr(1, 'Fajr'),
  dhuhr(2, 'Dhuhr'),
  asr(3, 'Asr'),
  maghrib(4, 'Maghrib'),
  isha(5, 'Isha');

  final int notificationId;
  final String displayName;
  const Prayer(this.notificationId, this.displayName);
}

Future<void> schedulePrayerNotifications({BuildContext? buildContext}) async {
  final prefs = await SharedPreferences.getInstance();
  final prayerTimes = await getPrayerTimes(buildContext: buildContext);
  await _cancelAllPrayerNotifications();

  for (final prayer in Prayer.values) {
    if (await _isPrayerEnabled(prayer.name.toLowerCase(), prefs)) {
      await schedulePrayerNotification(
        prayer: prayer,
        scheduledDate: getPrayerTime(prayer, prayerTimes),
      );
    }
  }
}

DateTime getPrayerTime(Prayer prayer, PrayerTimes? prayerTimes) {
  if (prayerTimes == null) {
    return DateTime.now();
  }
  switch (prayer) {
    case Prayer.fajr:
      return prayerTimes.fajr;
    case Prayer.dhuhr:
      return prayerTimes.dhuhr;
    case Prayer.asr:
      return prayerTimes.asr;
    case Prayer.maghrib:
      return prayerTimes.maghrib;
    case Prayer.isha:
      return prayerTimes.isha;
  }
}

Future<void> schedulePrayerNotification({
  required Prayer prayer,
  required DateTime scheduledDate,
}) async {
  await LocalNotification.scheduleANotification(
    id: prayer.notificationId,
    title: '${prayer.displayName} Prayer',
    body: 'It is time for ${prayer.displayName} prayer.',
    scheduledDate: scheduledDate,
    sound: 'adhan',
  );
}

Future<bool> _isPrayerEnabled(String prayer, SharedPreferences prefs) async {
  final storeValue = prefs.getBool("${prayer}Enabled");
  if (storeValue == null) {
    await prefs.setBool("${prayer}Enabled", true);
    return true;
  }
  return storeValue;
}

Future<void> _cancelAllPrayerNotifications() async {
  for (final prayer in Prayer.values) {
    await LocalNotification.cancelNotification(prayer.notificationId);
  }
}

Future<Map<String, bool>> getPrayerStatus() async {
  final prefs = await SharedPreferences.getInstance();
  final Map<String, bool> status = {};

  for (final prayer in Prayer.values) {
    status[prayer.displayName] =
        await _isPrayerEnabled(prayer.displayName.toLowerCase(), prefs);
  }

  return status;
}
