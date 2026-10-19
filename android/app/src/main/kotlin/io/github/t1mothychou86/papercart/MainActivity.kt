// CN: Papercart package and notification branding (A1).
package io.github.t1mothychou86.papercart

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Create notification channel for foreground service on Android 8.0 and above
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "papercart_channel",
                "Papercart Updates",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notification when new articles from followed journals and saved queries are available"
            }

            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }
}
