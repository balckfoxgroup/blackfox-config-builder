package com.blackfoxvpnn.configbuilder

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            ENGINE_CHANNEL,
        ).setMethodCallHandler(ConfigBuilderHandler(this))
    }

    companion object {
        private const val ENGINE_CHANNEL = "com.blackfoxvpnn.configbuilder/engine"
    }
}
