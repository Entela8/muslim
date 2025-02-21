import 'package:flutter/material.dart';
import 'package:muslim_alim/components/daily_azkar/minutes_selector.dart';
import 'package:muslim_alim/services/local_notification_service.dart';
import 'package:muslim_alim/utils/prayer_times/get_prayer_times.dart';
import 'package:muslim_alim/utils/string_to_time_of_day.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<TimeOfDay?> handleSetAskarAlMasaaModeToManually(
    BuildContext context, TimeOfDay initialTime) async {
  TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: initialTime,
    builder: (BuildContext context, Widget? child) {
      return Theme(data: ThemeData.dark(), child: child!);
    },
  );
  if (pickedTime == null) {
    return null;
  }

  await scheduleAskarAlMasaaNotification(pickedTime);
  await storeTimeOfDayAtPrefs(pickedTime, 'askarAlMasaaTime');

  final prefs = await SharedPreferences.getInstance();
  prefs.setString('askarAlMasaaMode', 'manually');

  return pickedTime;
}

Future<TimeOfDay?> handleSetAskarAlMasaaModeToAutomatically(
    BuildContext context) async {
  int? minutesFromAsr = await showMinutesSelector(
      title: 'Combien de minutes après Asr ?', context: context);
  final prayerTimes = await getPrayerTimes();

  if (prayerTimes == null || minutesFromAsr == null) {
    return null;
  }

  // add minutesFromAsr to Asr
  DateTime asrTime = prayerTimes.asr;
  final asrPlusMinutes =
      TimeOfDay.fromDateTime(asrTime.add(Duration(minutes: minutesFromAsr)));

  await scheduleAskarAlMasaaNotification(asrPlusMinutes);
  await storeTimeOfDayAtPrefs(asrPlusMinutes, 'askarAlMasaaTime');

  final prefs = await SharedPreferences.getInstance();
  prefs.setString('askarAlMasaaMode', 'automatically');
  return asrPlusMinutes;
}

Future<void> scheduleAskarAlMasaaNotification(TimeOfDay targetTime) async {
  await LocalNotification.showRepeatingNotificationEachDay(
      id: 8,
      title: 'Askar Al Masaa',
      body: 'Il est temps de prier Askar Al Masaa.',
      time: targetTime);
}

Future<void> cancelAskarAlMasaaNotification() async {
  await LocalNotification.cancelNotification(7);
}
