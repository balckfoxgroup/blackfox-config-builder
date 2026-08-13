package com.blackfoxvpnn.configbuilder

import android.content.Context
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import mobile.Mobile

class ConfigBuilderHandler(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "init" -> {
                try {
                    val err = Mobile.init(context.filesDir.absolutePath)
                    if (err.isNullOrEmpty()) {
                        result.success(null)
                    } else {
                        result.error("init_failed", err, null)
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "init failed", e)
                    result.error("init_failed", e.message, null)
                }
            }
            "connectPanel" -> runGo(result) {
                Mobile.connectPanelJSON(call.argument("settings") ?: "{}")
            }
            "disconnectPanel" -> runGo(result) {
                Mobile.disconnectPanelJSON()
            }
            "connectionStatus" -> runGo(result) {
                Mobile.panelConnectionStatusJSON()
            }
            "testConnection" -> runGo(result) {
                Mobile.testPanelConnectionJSON(call.argument("settings") ?: "{}")
            }
            "createClient" -> runGo(result) {
                Mobile.createClientJSON(
                    call.argument("settings") ?: "{}",
                    call.argument("request") ?: "{}",
                )
            }
            "createBulk" -> runGo(result) {
                Mobile.createBulkJSON(
                    call.argument("settings") ?: "{}",
                    call.argument("request") ?: "{}",
                )
            }
            "deleteClient" -> runGo(result) {
                Mobile.deleteClientJSON(
                    call.argument("settings") ?: "{}",
                    call.argument("request") ?: "{}",
                )
            }
            "listInbounds" -> runGo(result) {
                Mobile.listInboundsJSON(call.argument("settings") ?: "{}")
            }
            "installApk" -> {
                val path = call.argument<String>("path")
                if (path.isNullOrBlank()) {
                    result.error("invalid_args", "path required", null)
                    return@onMethodCall
                }
                try {
                    ApkInstaller.install(context, path)
                    result.success(null)
                } catch (e: Exception) {
                    Log.e(TAG, "installApk failed", e)
                    result.error("install_failed", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun runGo(result: MethodChannel.Result, block: () -> String) {
        Thread {
            try {
                result.success(block())
            } catch (e: Exception) {
                Log.e(TAG, "go call failed", e)
                result.error("go_error", e.message, null)
            }
        }.start()
    }

    companion object {
        private const val TAG = "ConfigBuilderHandler"
    }
}
