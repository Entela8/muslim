import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:muslim_alim/js_handlers/disable_prayer_notification.dart';
import 'package:muslim_alim/js_handlers/enable_prayer_notification.dart';
import 'package:muslim_alim/js_handlers/navigate_to_settings.dart';
import 'package:muslim_alim/js_handlers/share.dart';
import 'package:muslim_alim/services/location_service.dart';
import 'package:muslim_alim/services/prayer_notification_service.dart';
import 'package:muslim_alim/services/widget_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  WebViewController? _webViewController;

  Future<WebViewController> _initializeWebView() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (prefs.getBool('shouldSchedulePrayerNotifications') ?? false) {
        await schedulePrayerNotifications(buildContext: context);
        prefs.setBool('shouldSchedulePrayerNotifications', false);
      }

      if (prefs.getBool('shouldUpdateWidgetLocation') ?? false) {
        WidgetService.updateWidgetLocation();
        prefs.setBool('shouldUpdateWidgetLocation', false);
      }

      Coordinates position = await getPositionCoordinates();

      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..enableZoom(false)
        ..setBackgroundColor(const Color.fromARGB(255, 0, 0, 39))
        // Override geolocation before loading the page
        ..setNavigationDelegate(NavigationDelegate(
          onPageFinished: (url) async {
            // Pass position to JavaScript after page loads
            if (url.contains('https://muslim-alim.com/horaires-prieres.html')) {
              final prayerStatus = await getPrayerStatus();
              _webViewController?.runJavaScript('''
                    activeAdhans = {
                     Fajr: ${prayerStatus['Fajr']},
                     Dhuhr: ${prayerStatus['Dhuhr']},
                     Asr: ${prayerStatus['Asr']},
                     Maghrib: ${prayerStatus['Maghrib']},
                     Isha: ${prayerStatus['Isha']}
                   };
                ''');
            }
            _webViewController?.runJavaScript('''
                  handleLocationSuccess({
                    coords: {
                      latitude: ${position.latitude},
                      longitude: ${position.longitude}
                    }
                  });
                ''');
          },
          onWebResourceError: (error) {
            debugPrint('Web resource error: ${error.description}');
          },
        ))
        ..addJavaScriptChannel('flutter_inappwebview',
            onMessageReceived: (JavaScriptMessage message) {
          handleNavigateToSettings(message.message, context);
          handleDisablePrayerNotification(message.message);
          handleEnablePrayerNotification(message.message);
          handleShare(message.message);
        })
        ..loadRequest(Uri.parse('https://muslim-alim.com/accueil.html'));
      return _webViewController!;
    } catch (e) {
      return _webViewController!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_webViewController != null) {
          if (await _webViewController!.canGoBack()) {
            await _webViewController!.goBack();
            return false;
          } else {
            Navigator.of(context).pop();
            return true;
          }
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 0, 0, 39),
        body: SafeArea(
          child: FutureBuilder<WebViewController>(
            future: _initializeWebView(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }
                return WebViewWidget(
                  controller: snapshot.data!,
                );
              }
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }
}
