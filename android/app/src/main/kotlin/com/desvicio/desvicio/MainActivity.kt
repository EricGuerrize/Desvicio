package com.desvicio.desvicio

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val storage = getSharedPreferences("desvicio", MODE_PRIVATE)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.desvicio.app/control")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getState" -> result.success(mapOf(
                        "configured" to false,
                        "name" to (storage.getString("name", "Pingo") ?: "Pingo"),
                        "mood" to 0,
                        "selectedCount" to 0,
                        "limitMinutes" to storage.getInt("limitMinutes", 120),
                        "focusMinutes" to 0
                    ))
                    "saveName" -> {
                        val name = call.argument<String>("name")?.trim()?.take(20)
                        storage.edit().putString("name", name?.ifEmpty { "Pingo" } ?: "Pingo").apply()
                        result.success(null)
                    }
                    "saveLimit" -> {
                        val minutes = call.argument<Int>("minutes") ?: 120
                        storage.edit().putInt("limitMinutes", minutes).apply()
                        result.success(null)
                    }
                    "eraseData" -> {
                        storage.edit().clear().apply()
                        result.success(null)
                    }
                    else -> result.error("ANDROID_PENDING",
                        "O controle de apps no Android ainda está em desenvolvimento.", null)
                }
            }
    }
}
