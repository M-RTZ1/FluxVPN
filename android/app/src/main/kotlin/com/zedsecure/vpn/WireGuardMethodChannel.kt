package com.zedsecure.vpn

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File

class WireGuardMethodChannel {
    companion object {
        private const val CHANNEL = "com.zedsecure.vpn/wireguard"

        fun registerWith(flutterEngine: FlutterEngine, context: Context) {
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "initializeWireGuardPaths" -> {
                        initializeWireGuardPaths(context, result)
                    }
                    "getWireGuardStateDir" -> {
                        result.success(getWireGuardStateDir(context).absolutePath)
                    }
                    "getWireGuardPeerStats" -> {
                        val interfaceName = call.argument<String>("interfaceName") ?: "wg0"
                        getWireGuardPeerStats(interfaceName, result)
                    }
                    else -> result.notImplemented()
                }
            }
        }

        /**
         * Initialize WireGuard paths to use app-specific directories instead of the default
         * com.wireguard.android.debug package
         */
        private fun initializeWireGuardPaths(context: Context, result: Result) {
            try {
                val wgStateDir = getWireGuardStateDir(context)
                val wgConfigDir = getWireGuardConfigDir(context)

                // Create directories if they don't exist
                if (!wgStateDir.exists()) {
                    wgStateDir.mkdirs()
                }
                if (!wgConfigDir.exists()) {
                    wgConfigDir.mkdirs()
                }

                // Set environment variables for WireGuard Go backend
                System.setProperty("wireguard.state.dir", wgStateDir.absolutePath)
                System.setProperty("wireguard.config.dir", wgConfigDir.absolutePath)

                result.success(
                        mapOf(
                                "stateDir" to wgStateDir.absolutePath,
                                "configDir" to wgConfigDir.absolutePath,
                                "success" to true
                        )
                )
            } catch (e: Exception) {
                result.error(
                        "WIREGUARD_INIT_ERROR",
                        "Failed to initialize WireGuard paths: ${e.message}",
                        e.stackTraceToString()
                )
            }
        }

        /** Get WireGuard state directory (for runtime state like sockets) */
        private fun getWireGuardStateDir(context: Context): File {
            return File(context.cacheDir, "wireguard/state")
        }

        /** Get WireGuard config directory (for configuration files) */
        private fun getWireGuardConfigDir(context: Context): File {
            return File(context.filesDir, "wireguard/config")
        }

        /**
         * Get WireGuard peer statistics including handshake info This is used for health checking -
         * if lastHandshakeTime > 0, connection is healthy
         */
        private fun getWireGuardPeerStats(interfaceName: String, result: Result) {
            try {
                // Placeholder implementation
                // In production, this would query the WireGuard UAPI socket
                // to get actual peer stats (lastHandshakeTime, bytesReceived, bytesSent)

                val stats =
                        mapOf(
                                "lastHandshakeTime" to 0L,
                                "bytesReceived" to 0L,
                                "bytesSent" to 0L,
                                "interfaceName" to interfaceName
                        )

                result.success(stats)
            } catch (e: Exception) {
                result.error(
                        "WIREGUARD_STATS_ERROR",
                        "Failed to get WireGuard peer stats: ${e.message}",
                        e.stackTraceToString()
                )
            }
        }
    }
}
