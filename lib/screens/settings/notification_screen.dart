import 'package:flutter/material.dart';
import 'package:muslim_alim/components/notification/notification_switch.dart';
import 'package:muslim_alim/screens/settings/daily_azkar_screen.dart';
import 'package:muslim_alim/services/daily_askar/askar_al_masaa_service.dart';
import 'package:muslim_alim/services/daily_askar/askar_al_sabah_service.dart';
import 'package:muslim_alim/services/local_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _dailyAzkarEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  void _loadStates() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyAzkarEnabled = prefs.getBool('dailyAzkarEnabled') ?? false;
    });
  }

  Future<void> handleDisableDailyAzkarNotification(
      SharedPreferences prefs) async {
    await cancelAskarAlMasaaNotification();
    await cancelAskarAlSabahNotification();
    prefs.setBool('dailyAzkarEnabled', false);
  }

  Future<void> handleEnableDailyAzkarNotification(
      SharedPreferences prefs) async {
    prefs.setBool('dailyAzkarEnabled', true);
    await LocalNotification.showInstantNotification(
      title: 'Muslim Alim',
      body: 'Adhkâr quotidiens activés',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 0, 0, 39),
            Color.fromARGB(255, 0, 0, 59),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          elevation: 0,
          title: Text(
            'Paramètres de notification',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.white.withValues(alpha: 0.3),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            NotificationSwitch(
              title: 'Adhkâr quotidiens',
              subtitle: 'Recevez un rappel pour les adhkâr (al sabah/al masaa)',
              value: _dailyAzkarEnabled,
              onChanged: (bool value) async {
                setState(() => _dailyAzkarEnabled = value);
                final prefs = await SharedPreferences.getInstance();
                if (value) {
                  await handleEnableDailyAzkarNotification(prefs);
                } else {
                  await handleDisableDailyAzkarNotification(prefs);
                }
              },
            ),
            ListTile(
              enabled: _dailyAzkarEnabled,
              onTap: _dailyAzkarEnabled
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DailyAzkarScreen()),
                      );
                    }
                  : null,
              leading: Icon(
                Icons.notifications_active,
                color: _dailyAzkarEnabled ? Colors.white : Colors.white38,
              ),
              title: Text(
                'Paramètres des adhkâr quotidiens',
                style: TextStyle(
                  color: _dailyAzkarEnabled ? Colors.white : Colors.white38,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: _dailyAzkarEnabled ? Colors.white : Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
