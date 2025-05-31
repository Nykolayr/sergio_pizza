package com.sergio.pizza

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine  // Этот импорт критически важен!
import com.yandex.mapkit.MapKitFactory

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MapKitFactory.setApiKey("b5979b78-e513-40f3-9090-4929f3d65324")
    }
}