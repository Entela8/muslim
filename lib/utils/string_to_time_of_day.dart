import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> storeTimeOfDayAtPrefs(TimeOfDay time, String nameInPrefs) async {
  final prefs = await SharedPreferences.getInstance();
  String timeString = "${time.hour}:${time.minute}";
  await prefs.setString(nameInPrefs, timeString);
}

Future<TimeOfDay?> getTimeOfDay({required String nameInPrefs}) async {
  final prefs = await SharedPreferences.getInstance();
  String? timeString = prefs.getString(nameInPrefs);
  if (timeString != null) {
    List<String> timeParts = timeString.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }
  return null;
}

String formatTimeOfDay(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return "$hour:$minute";
}
