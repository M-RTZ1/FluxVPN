package com.zedsecure.vpn

import android.app.Activity
import android.content.Intent
import android.net.VpnService
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val VPN_CONTROL_CHANNEL = "com.zedsecure.vpn/vpn_control"
    private val VPN_PERMISSION_CHANNEL = "com.zedsecure.vpn/permission"
    private val VPN_PERMISSION_REQUEST_CODE = 7777
    
    private var vpnControlChannel: MethodChannel? = null
    private var vpnPermissionChannel: MethodChannel? = null
    private var pendingVpnPermissionResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        PingMethodChannel.registerWith(flutterEngine, context)
        AppListMethodChannel.registerWith(flutterEngine, context)
        SettingsMethodChannel.registerWith(flutterEngine, context)
        WireGuardMethodChannel.registerWith(flutterEngine, context)
        
        vpnControlChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VPN_CONTROL_CHANNEL)
        
        // VPN Permission Channel
        vpnPermissionChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VPN_PERMISSION_CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestVpnPermission" -> {
                        requestVpnPermission(result)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }
    
    private fun requestVpnPermission(result: MethodChannel.Result) {
        val intent = VpnService.prepare(this)
        if (intent != null) {
            // Permission not granted, request it
            pendingVpnPermissionResult = result
            startActivityForResult(intent, VPN_PERMISSION_REQUEST_CODE)
        } else {
            // Permission already granted
            result.success(true)
        }
    }
    
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        if (requestCode == VPN_PERMISSION_REQUEST_CODE) {
            val granted = resultCode == Activity.RESULT_OK
            pendingVpnPermissionResult?.success(granted)
            pendingVpnPermissionResult = null
        }
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }
    
    override fun onResume() {
        super.onResume()
        handleIntent(intent)
    }
    
    private fun handleIntent(intent: Intent?) {
        if (intent?.action == "FROM_DISCONNECT_BTN") {
            vpnControlChannel?.invokeMethod("disconnectFromNotification", null)
        }
    }
}
