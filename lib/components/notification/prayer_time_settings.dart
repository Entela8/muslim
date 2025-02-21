import 'package:flutter/material.dart';
import 'package:muslim_alim/components/notification/country_selector.dart';

class PrayerTimeSettings extends StatefulWidget {
  final bool isEnabled;
  final Function(bool) onChanged;

  const PrayerTimeSettings({
    super.key,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  State<PrayerTimeSettings> createState() => _PrayerTimeSettingsState();
}

class _PrayerTimeSettingsState extends State<PrayerTimeSettings> {
  bool _automaticLocation = true;
  String _selectedCountry = '';

  void _showSoundSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromARGB(255, 0, 0, 39),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Auto-set location',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSoundOption(
                    'Automatic',
                    true,
                    _automaticLocation,
                    (value) {
                      _automaticLocation = value;
                      Navigator.pop(context);
                    },
                  ),
                  _buildSoundOption(
                    'Manual',
                    false,
                    _automaticLocation,
                    (value) {
                      _automaticLocation = value;
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showCountrySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CountrySelector(
        onSelect: (country) {
          setState(() {
            _selectedCountry = country;
          });
        },
      ),
    );
  }

  Widget _buildSoundOption(
    String label,
    bool value,
    bool groupValue,
    Function(bool) onChanged,
  ) {
    return InkWell(
      onTap: () => {
        onChanged(value),
        setState(() {}),
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: groupValue == value
              ? Colors.green.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: groupValue == value ? Colors.green : Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: groupValue == value ? Colors.green : Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          enabled: widget.isEnabled,
          onTap: widget.isEnabled ? _showSoundSettings : null,
          leading: Icon(
            Icons.notifications_active,
            color: widget.isEnabled ? Colors.white : Colors.white38,
          ),
          title: Text(
            'Auto-set location',
            style: TextStyle(
              color: widget.isEnabled ? Colors.white : Colors.white38,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: widget.isEnabled ? Colors.white : Colors.white38,
          ),
        ),
        ListTile(
          enabled: !_automaticLocation && widget.isEnabled,
          leading: Icon(
            Icons.location_on,
            color: (!_automaticLocation && widget.isEnabled)
                ? Colors.white
                : Colors.white38,
          ),
          title: Text(
            _selectedCountry.isEmpty ? 'Select Country' : _selectedCountry,
            style: TextStyle(
              color: (!_automaticLocation && widget.isEnabled)
                  ? Colors.white
                  : Colors.white38,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: (!_automaticLocation && widget.isEnabled)
                ? Colors.white
                : Colors.white38,
          ),
          onTap: (!_automaticLocation && widget.isEnabled)
              ? _showCountrySelector
              : null,
        ),
      ],
    );
  }
}
