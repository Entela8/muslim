package appmuslimalimcom.wpapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import androidx.core.content.ContextCompat
import android.widget.RemoteViews
import com.batoulapps.adhan2.CalculationMethod
import com.batoulapps.adhan2.Coordinates
import com.batoulapps.adhan2.PrayerTimes
import com.batoulapps.adhan2.data.DateComponents
import kotlin.time.Duration.Companion.seconds
import kotlin.time.toJavaDuration
import kotlinx.datetime.*
import java.time.format.DateTimeFormatter
import java.time.LocalTime
import java.time.ZoneId
import java.util.Locale
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject

class PrayerTimesWidgetProvider : AppWidgetProvider() {
    companion object {
        private const val PREFS_NAME = "PrayerWidgetPrefs"
        private const val KEY_LATITUDE = "latitude"
        private const val KEY_LONGITUDE = "longitude"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val views = RemoteViews(context.packageName, R.layout.prayer_times_widget_layout)
        
        // Get location from SharedPreferences
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val latitude = prefs.getFloat(KEY_LATITUDE, Float.MIN_VALUE)
        val longitude = prefs.getFloat(KEY_LONGITUDE, Float.MIN_VALUE)

        if (latitude == Float.MIN_VALUE || longitude == Float.MIN_VALUE) {
            // Show message when location is not available
            views.setTextViewText(R.id.next_prayer, "Localisation non disponible")
            views.setTextViewText(R.id.next_prayer_time, "Ouvrez l'application pour mettre à jour")
            views.setTextViewText(R.id.fajr_time, "")
            views.setTextViewText(R.id.dhuhr_time, "")
            views.setTextViewText(R.id.asr_time, "")
            views.setTextViewText(R.id.maghrib_time, "")
            views.setTextViewText(R.id.isha_time, "")
            appWidgetManager.updateAppWidget(appWidgetId, views)
            return
        }

        // Create OkHttpClient
        val client = OkHttpClient()
        
        // Build URL with query parameters
        val nowInstant = Clock.System.now()
        val url = "https://api.aladhan.com/v1/timings?" + "latitude=$latitude&longitude=$longitude"
        
        // Create request
        val request = Request.Builder()
            .url(url)
            .build()

        // Execute network request in background thread
        Thread {
            try {
                val response = client.newCall(request).execute()
                val responseBody = response.body?.string() ?: throw Exception("Empty response")
                val jsonData = JSONObject(responseBody)
                
                if (!response.isSuccessful) {
                    throw Exception("API request failed: ${jsonData.optString("data", "Unknown error")}")
                }
                
                val data = jsonData.optJSONObject("data")
                if (data == null) {
                    throw Exception("Invalid API response format")
                }
                
                val timings = data.getJSONObject("timings")
                
                // Show the next prayer
                val currentTime = java.time.LocalTime.now()
                val prayers = listOf(
                    "Fajr" to parseTime(timings.getString("Fajr")),
                    "Dhuhr" to parseTime(timings.getString("Dhuhr")),
                    "Asr" to parseTime(timings.getString("Asr")),
                    "Maghrib" to parseTime(timings.getString("Maghrib")),
                    "Isha" to parseTime(timings.getString("Isha"))
                )
                
                val nextPrayer = prayers.firstOrNull { it.second.isAfter(currentTime) }
                    ?: prayers.first() // If all prayers passed, show first prayer of next day

                // Update next prayer view
                views.setTextViewText(R.id.next_prayer, "Prochaine prière: ${translatePrayerName(nextPrayer.first)}")
                views.setTextViewText(R.id.next_prayer_time, nextPrayer.second.format(DateTimeFormatter.ofPattern("HH:mm")))

                // Update widget UI
                views.setTextViewText(R.id.fajr_time, "${translatePrayerName("Fajr")}: ${timings.getString("Fajr")}")
                views.setTextViewText(R.id.dhuhr_time, "${translatePrayerName("Dhuhr")}: ${timings.getString("Dhuhr")}")
                views.setTextViewText(R.id.asr_time, "${translatePrayerName("Asr")}: ${timings.getString("Asr")}")
                views.setTextViewText(R.id.maghrib_time, "${translatePrayerName("Maghrib")}: ${timings.getString("Maghrib")}")
                views.setTextViewText(R.id.isha_time, "${translatePrayerName("Isha")}: ${timings.getString("Isha")}")

                // Update the widget
                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (e: Exception) {
                e.printStackTrace()
                // Fallback to local calculation if API fails
                val coordinates = Coordinates(latitude.toDouble(), longitude.toDouble())
                val params = CalculationMethod.EGYPTIAN.parameters
                val dateComponents = DateComponents.from(nowInstant)
                val prayerTimes = PrayerTimes(coordinates, dateComponents, params)
                
                // Update widget with local calculations
                views.setTextViewText(R.id.fajr_time, prayerTimes.fajr.toString())
                views.setTextViewText(R.id.dhuhr_time, prayerTimes.dhuhr.toString())
                views.setTextViewText(R.id.asr_time, prayerTimes.asr.toString())
                views.setTextViewText(R.id.maghrib_time, prayerTimes.maghrib.toString())
                views.setTextViewText(R.id.isha_time, prayerTimes.isha.toString())
                
                appWidgetManager.updateAppWidget(appWidgetId, views)
            }
        }.start()
    }

    private fun hasLocationPermission(context: Context): Boolean {
        return ContextCompat.checkSelfPermission(
            context,
            android.Manifest.permission.ACCESS_FINE_LOCATION
        ) == android.content.pm.PackageManager.PERMISSION_GRANTED ||
        ContextCompat.checkSelfPermission(
            context,
            android.Manifest.permission.ACCESS_COARSE_LOCATION
        ) == android.content.pm.PackageManager.PERMISSION_GRANTED
    }

    private fun Instant.toFormattedString(): String {
        val timeFormatter = DateTimeFormatter.ofPattern("HH:mm").withZone(ZoneId.systemDefault())
        return toJavaInstant()
            .atZone(ZoneId.systemDefault())
            .toLocalTime()
            .format(timeFormatter)
    }

    private fun parseTime(timeStr: String): LocalTime {
        return LocalTime.parse(timeStr, DateTimeFormatter.ofPattern("HH:mm"))
    }

    private fun translatePrayerName(prayer: String): String {
        return when (prayer) {
            "Fajr" -> "Fajr"
            "Dhuhr" -> "Dhohr"
            "Asr" -> "Asr"
            "Maghrib" -> "Maghreb"
            "Isha" -> "Icha"
            else -> prayer
        }
    }
}
