package com.example.geotag

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.provider.Settings

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.geotag/settings"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "isAutoRotationEnabled") {
                try {
                    val isEnabled = Settings.System.getInt(contentResolver, Settings.System.ACCELEROMETER_ROTATION, 0) == 1
                    result.success(isEnabled)
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", "Could not read setting.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
