import 'package:flutter/material.dart';
import 'package:muslim_alim/components/daily_azkar/minutes_selector.dart';
import 'package:muslim_alim/services/local_notification_service.dart';
import 'package:muslim_alim/utils/prayer_times/get_prayer_times.dart';
import 'package:muslim_alim/utils/string_to_time_of_day.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<TimeOfDay?> handleSetAskarAlSabahModeToManually(
    BuildContext context, TimeOfDay currentTime) async {
  TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: currentTime,
    builder: (BuildContext context, Widget? child) {
      return Theme(data: ThemeData.dark(), child: child!);
    },
  );
  if (pickedTime == null) {
    return null;
  }
  await storeTimeOfDayAtPrefs(pickedTime, 'askarAlSabahTime');
  await scheduleAskarAlSabahNotification(pickedTime);

  final prefs = await SharedPreferences.getInstance();
  prefs.setString('askarAlSabahMode', 'manually');
  return pickedTime;
}

Future<TimeOfDay?> handleSetAskarAlSabahModeToAutomatically(
    BuildContext context) async {
  int? minutesFromAsr = await showMinutesSelector(
      title: 'Combien de minutes après Fajr ?', context: context);
  if (minutesFromAsr == null) {
    return null;
  }
  final prayerTimes = await getPrayerTimes();
  if (prayerTimes == null) {
    return null;
  }
  // add minutesFromAsr to Asr
  DateTime asrTime = prayerTimes.fajr;
  final asrPlusMinutes =
      TimeOfDay.fromDateTime(asrTime.add(Duration(minutes: minutesFromAsr)));

  await scheduleAskarAlSabahNotification(asrPlusMinutes);
  await storeTimeOfDayAtPrefs(asrPlusMinutes, 'askarAlSabahTime');

  final prefs = await SharedPreferences.getInstance();
  prefs.setString('askarAlSabahMode', 'automatically');
  return asrPlusMinutes;
}

Future<void> scheduleAskarAlSabahNotification(TimeOfDay targetTime) async {
  await LocalNotification.showRepeatingNotificationEachDay(
      id: 6,
      title: 'Prieres du matin',
      body: 'Il est temps de prier les pri res du matin.',
      time: targetTime);
}

Future<void> cancelAskarAlSabahNotification() async {
  await LocalNotification.cancelNotification(6);
}
