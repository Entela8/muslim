import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AzkarTimeSetter extends StatefulWidget {
  final String mode;
  final bool enable;
  final String title;
  final TimeOfDay currentTime;

  final Future<void> Function(String mode) onSetModeTo;

  const AzkarTimeSetter(
      {super.key,
      required this.mode,
      required this.enable,
      required this.currentTime,
      required this.title,
      required this.onSetModeTo});

  @override
  State<AzkarTimeSetter> createState() => _AzkarTimeSetterState();
}

class _AzkarTimeSetterState extends State<AzkarTimeSetter> {
  bool showAutomaticallyTimeDialog = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16, 16.0, 16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          widget.title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: widget.enable ? Colors.white : Colors.white24,
          ),
        ),
        Column(children: [
          Row(
            children: [
              Radio(
                value: 'manually',
                groupValue: widget.mode,
                onChanged: widget.enable
                    ? (String? value) async =>
                        await widget.onSetModeTo('manually')
                    : null,
                activeColor: Colors.blue,
              ),
              GestureDetector(
                onTap: widget.enable
                    ? () async => await widget.onSetModeTo('manually')
                    : null,
                child: Text(
                  'Manuellement',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: widget.enable ? Colors.white : Colors.white24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              Radio(
                value: 'automatically',
                groupValue: widget.mode,
                onChanged: widget.enable
                    ? (String? value) async =>
                        await widget.onSetModeTo('automatically')
                    : null,
                activeColor: Colors.blue,
              ),
              GestureDetector(
                onTap: widget.enable
                    ? () async => await widget.onSetModeTo('automatically')
                    : null,
                child: Text(
                  'Automatiquement',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: widget.enable ? Colors.white : Colors.white24,
                  ),
                ),
              ),
            ],
          ),
        ]),
      ]),
    );
  }
}
