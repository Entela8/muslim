import 'package:flutter/material.dart';
import 'package:muslim_alim/services/location_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/PrayerTimes.dart';

Future<PrayerTimes?> getPrayerTimes({BuildContext? buildContext}) async {
  // Calculate user location
  final coordinates = await getPositionCoordinates(buildContext);

  try {
    // Call Aladhan API
    final response = await http.get(Uri.parse(
        'https://api.aladhan.com/v1/timings?latitude=${coordinates.latitude}&longitude=${coordinates.longitude}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final timings = data['data']['timings'];

      // Parse API response into DateTime objects
      final fajr = _parseTime(timings['Fajr']);
      final sunrise = _parseTime(timings['Sunrise']);
      final dhuhr = _parseTime(timings['Dhuhr']);
      final asr = _parseTime(timings['Asr']);
      final maghrib = _parseTime(timings['Maghrib']);
      final isha = _parseTime(timings['Isha']);

      // Create PrayerTimes object with API data
      return PrayerTimes(
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha,
      );
    }
  } catch (e) {
    throw Exception('Échec de la récupération des heures de prière: $e');
  }
  return null;
}

DateTime _parseTime(String timeStr) {
  final now = DateTime.now();
  final parts = timeStr.split(':');
  return DateTime(
      now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
}
