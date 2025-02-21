import 'package:flutter/material.dart';
import 'package:muslim_alim/screens/settings/notification_screen.dart';

void handleNavigateToSettings(String message, BuildContext context) {
  if (message == 'navigateToSettings') {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => NotificationScreen()));
  }
}
