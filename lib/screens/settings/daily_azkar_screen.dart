import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_alim/components/daily_azkar/activate_button.dart';
import 'package:muslim_alim/components/daily_azkar/azkar_time_setter.dart';
import 'package:muslim_alim/services/daily_askar/askar_al_masaa_service.dart';
import 'package:muslim_alim/services/daily_askar/askar_al_sabah_service.dart';
import 'package:muslim_alim/utils/string_to_time_of_day.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyAzkarScreen extends StatefulWidget {
  const DailyAzkarScreen({super.key});

  @override
  State<DailyAzkarScreen> createState() => _DailyAzkarScreenState();
}

class _DailyAzkarScreenState extends State<DailyAzkarScreen> {
  late bool _askarAlSabahEnabled;
  late bool _askarAlMasaaEnabled;
  late String _askarAlSabahMode;
  late String _askarAlMasaaMode;
  late TimeOfDay _askarAlSabahTime;
  late TimeOfDay _askarAlMasaaTime;

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  Future<void> _loadStates() async {
    final prefs = await SharedPreferences.getInstance();
    _askarAlSabahEnabled = prefs.getBool('askarAlSabahEnabled') ?? true;
    _askarAlMasaaEnabled = prefs.getBool('askarAlMasaaEnabled') ?? true;
    _askarAlSabahTime = await getTimeOfDay(nameInPrefs: 'askarAlSabahTime') ??
        TimeOfDay(hour: 5, minute: 15);
    _askarAlMasaaTime = await getTimeOfDay(nameInPrefs: 'askarAlMasaaTime') ??
        TimeOfDay(hour: 19, minute: 15);
    _askarAlSabahMode = prefs.getString('askarAlSabahMode') ?? 'automatically';
    _askarAlMasaaMode = prefs.getString('askarAlMasaaMode') ?? 'automatically';
    setState(() {});
  }

  // Askar Al Sabah handlers
  /// Handles a change in the Askar Al Sabah activation state.
  ///
  /// If [value] is true, the Askar Al Sabah notification is scheduled to be
  /// sent at [_askarAlSabahTime]. If [value] is false, the Askar Al Sabah
  /// notification is cancelled.
  ///
  /// This function also updates the state of the Askar Al Sabah activation
  /// in the SharedPreferences.
  Future<void> _handleAskarAlSabahActivationChange(bool value) async {
    setState(() => _askarAlSabahEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('askarAlSabahEnabled', value);
    if (value) {
      await scheduleAskarAlSabahNotification(_askarAlSabahTime);
    } else {
      await cancelAskarAlSabahNotification();
    }
  }

  /// Handles a change in the Askar Al Sabah mode.
  ///
  /// If [mode] is 'manually', the user is prompted to select a time of day.
  /// If [mode] is 'automatically', the Askar Al Sabah notification is scheduled
  /// to be sent at a time of day that is [minutesFromFajr] minutes after Fajr.
  ///
  /// If the user cancels the time selection, this function does nothing.
  ///
  /// If the user selects a time of day, this function updates the state of the
  /// Askar Al Sabah mode and the time of day for the Askar Al Sabah notification.
  ///
  Future<void> _handleAskarAlSabahSetMode(String mode) async {
    late TimeOfDay? pickedTime;
    if (mode == 'manually') {
      pickedTime =
          await handleSetAskarAlSabahModeToManually(context, _askarAlSabahTime);
    } else if (mode == 'automatically') {
      pickedTime = await handleSetAskarAlSabahModeToAutomatically(context);
    }
    if (pickedTime == null) {
      return;
    }
    setState(() {
      _askarAlSabahTime = pickedTime!;
      _askarAlSabahMode = mode;
    });
  }

  // Askar Al Masaa handlers
  /// Handles a change in the Askar Al Masaa activation state.
  ///
  /// If [value] is true, the Askar Al Masaa notification is scheduled to be
  /// sent at [_askarAlMasaaTime]. If [value] is false, the Askar Al Masaa
  /// notification is cancelled.
  ///
  /// This function also updates the state of the Askar Al Masaa activation
  /// in the SharedPreferences.
  ///
  Future<void> _handleAskarAlMasaaActivationChange(bool value) async {
    setState(() => _askarAlMasaaEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('askarAlMasaaEnabled', value);
    if (value) {
      await scheduleAskarAlMasaaNotification(_askarAlMasaaTime);
    } else {
      await cancelAskarAlMasaaNotification();
    }
  }

  /// Handles a change in the Askar Al Masaa mode.
  ///
  /// If [mode] is 'manually', the user is prompted to select the time of day
  /// for the Askar Al Masaa notification. The selected time is stored in the
  /// SharedPreferences.
  ///
  /// If [mode] is 'automatically', the Askar Al Masaa notification is
  /// scheduled to be sent 30 minutes after the Asr prayer time.
  ///
  /// This function also updates the state of the Askar Al Masaa mode
  /// in the SharedPreferences.
  Future<void> _handleAskarAlMasaaSetMode(String mode) async {
    late TimeOfDay? pickedTime;
    if (mode == 'manually') {
      pickedTime =
          await handleSetAskarAlMasaaModeToManually(context, _askarAlMasaaTime);
    } else if (mode == 'automatically') {
      pickedTime = await handleSetAskarAlMasaaModeToAutomatically(context);
    }
    if (pickedTime == null) {
      return;
    }
    setState(() {
      _askarAlMasaaTime = pickedTime!;
      _askarAlMasaaMode = mode;
    });
  }

  @override

  /// The main widget for the daily azkar settings screen.
  ///
  /// This screen has a gradient background and a [Scaffold] with a transparent
  /// background. The [AppBar] is also transparent and has a white back button.
  /// The title of the [AppBar] is "Paramètres des adhkâr quotidiens".
  ///
  /// The body of the [Scaffold] is a [ListView] with two [ActivateButton]s and
  /// two [AzkarTimeSetter]s. The first [ActivateButton] and [AzkarTimeSetter]
  /// are for Askar Al Sabah and the second ones are for Askar Al Masaa.
  ///
  /// The [ActivateButton]s can be used to enable or disable the corresponding
  /// notification. The [AzkarTimeSetter]s can be used to set the time of day
  /// for the corresponding notification.
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
            ' adhkâr quotidiens',
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
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
          children: [
            ActivateButton(
              title: 'Adhkâr du matin ${formatTimeOfDay(_askarAlSabahTime)}',
              value: _askarAlSabahEnabled,
              onChanged: _handleAskarAlSabahActivationChange,
            ),
            if (_askarAlSabahEnabled)
              AzkarTimeSetter(
                title: 'Heure des adhkâr du matin',
                enable: _askarAlSabahEnabled,
                currentTime: _askarAlSabahTime,
                mode: _askarAlSabahMode,
                onSetModeTo: _handleAskarAlSabahSetMode,
              ),
            const Divider(color: Colors.white24),
            ActivateButton(
              title: 'Adhkâr du soir ${formatTimeOfDay(_askarAlMasaaTime)}',
              value: _askarAlMasaaEnabled,
              onChanged: _handleAskarAlMasaaActivationChange,
            ),
            if (_askarAlMasaaEnabled)
              AzkarTimeSetter(
                title: 'Heure des adhkâr du soir',
                enable: _askarAlMasaaEnabled,
                currentTime: _askarAlMasaaTime,
                mode: _askarAlMasaaMode,
                onSetModeTo: _handleAskarAlMasaaSetMode,
              ),
          ],
        ),
      ),
    );
  }
}
