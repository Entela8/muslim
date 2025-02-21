package appmuslimalimcom.wpapp

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent

class MainActivity: FlutterActivity() {
    private val CHANNEL = "appmuslimalimcom.wpapp/prayer_widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidgetLocation" -> {
                    val latitude = call.argument<Double>("latitude")
                    val longitude = call.argument<Double>("longitude")
                    
                    if (latitude == null || longitude == null) {
                        result.error("INVALID_ARGUMENTS", "Latitude and longitude are required", null)
                        return@setMethodCallHandler
                    }
                    
                    // Save location to SharedPreferences
                    val prefs = context.getSharedPreferences("PrayerWidgetPrefs", Context.MODE_PRIVATE)
                    prefs.edit().apply {
                        putFloat("latitude", latitude.toFloat())
                        putFloat("longitude", longitude.toFloat())
                        apply()
                    }
                    
                    // Update all widgets
                    val appWidgetManager = AppWidgetManager.getInstance(context)
                    val widgetComponent = ComponentName(context, PrayerTimesWidgetProvider::class.java)
                    val widgetIds = appWidgetManager.getAppWidgetIds(widgetComponent)
                    
                    // Trigger widget update
                    val updateIntent = Intent(context, PrayerTimesWidgetProvider::class.java).apply {
                        action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                        putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, widgetIds)
                    }
                    context.sendBroadcast(updateIntent)
                    
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
