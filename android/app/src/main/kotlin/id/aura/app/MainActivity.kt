package id.aura.app

import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Hosts the `id.aura.app/device_time` method channel used by the attendance
 * capture flow to enforce that the device clock is automatic (network-provided)
 * before an event is recorded — a defence against timestamp spoofing.
 *
 *  - `isAutomaticTimeEnabled` -> `true` only when BOTH `AUTO_TIME` and
 *    `AUTO_TIME_ZONE` are on, `false` when either is off, `null` when the value
 *    cannot be read (so the Dart side never hard-blocks on an unknown).
 *  - `openDateTimeSettings` -> opens the system Date & Time screen where the
 *    user can enable the automatic clock; returns whether it opened.
 */
class MainActivity : FlutterActivity() {
    private val channelName = "id.aura.app/device_time"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isAutomaticTimeEnabled" -> result.success(isAutomaticTimeEnabled())
                    "openDateTimeSettings" -> result.success(openDateTimeSettings())
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * `true` only when automatic date/time AND automatic time zone are both on,
     * `null` when the settings cannot be read (treated as "not verifiable").
     */
    private fun isAutomaticTimeEnabled(): Boolean? {
        return try {
            val autoTime = Settings.Global.getInt(contentResolver, Settings.Global.AUTO_TIME)
            val autoZone = Settings.Global.getInt(contentResolver, Settings.Global.AUTO_TIME_ZONE)
            autoTime == 1 && autoZone == 1
        } catch (_: Settings.SettingNotFoundException) {
            null
        }
    }

    private fun openDateTimeSettings(): Boolean {
        return try {
            startActivity(
                Intent(Settings.ACTION_DATE_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            )
            true
        } catch (_: Exception) {
            false
        }
    }
}
