import 'package:flutter/services.dart';
import 'package:muslim_alim/services/location_service.dart';

class WidgetService {
  static const platform = MethodChannel('appmuslimalimcom.wpapp/prayer_widget');

  static Future<void> updateWidgetLocation() async {
    try {
      final coordinates = await getPositionCoordinates();
      await platform.invokeMethod('updateWidgetLocation', {
        'latitude': coordinates.latitude,
        'longitude': coordinates.longitude,
      });
    } on PlatformException catch (e) {
      print('Failed to update widget location: ${e.message}');
    }
  }
}
