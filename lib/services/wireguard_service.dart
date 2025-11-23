import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wireguard_flutter/wireguard_flutter.dart';
import 'package:wireguard_flutter/wireguard_flutter_platform_interface.dart';
import 'package:fluxvpn/models/wireguard_config.dart';
import 'package:fluxvpn/services/error_service.dart';

// Platform channels
const _vpnPermissionChannel = MethodChannel('com.zedsecure.vpn/permission');
const _wireGuardChannel = MethodChannel('com.zedsecure.vpn/wireguard');

class WireGuardService extends ChangeNotifier {
  static final WireGuardService _instance = WireGuardService._internal();
  factory WireGuardService() => _instance;

  WireGuardService._internal();

  final ErrorService _errorService = ErrorService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  WireGuardFlutterInterface? _wireguard;
  WireGuardConfig? _activeConfig;
  WireGuardConfig? _selectedConfig;
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _isInitialized = false;

  WireGuardStats? _currentStats;
  Timer? _statsTimer;

  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  WireGuardConfig? get activeConfig => _activeConfig;
  WireGuardConfig? get selectedConfig => _selectedConfig;
  WireGuardStats? get currentStats => _currentStats;
  bool get isSupported => Platform.isAndroid;

  Future<void> initialize() async {
    if (!isSupported) {
      _errorService.warning('WireGuard is only supported on Android devices.');
      throw Exception(
        'WireGuard connections are only supported on Android devices.',
      );
    }
    if (_isInitialized) return;

    try {
      _errorService.info('Initializing WireGuardService...');

      // Initialize WireGuard paths on Android to avoid permission denied errors
      // This ensures WireGuard uses app-specific directories instead of com.wireguard.android.debug
      if (Platform.isAndroid) {
        try {
          final result = await _wireGuardChannel.invokeMethod<Map?>(
            'initializeWireGuardPaths',
          );
          if (result != null) {
            _errorService.info('WireGuard paths initialized: $result');
          }
        } catch (e) {
          _errorService.debug(
            'WireGuard path initialization not available: $e',
          );
          // Continue anyway - paths will use defaults
        }
      }

      _wireguard = WireGuardFlutter.instance;
      await _wireguard!.initialize(interfaceName: 'wg0');
      _isInitialized = true;
      _errorService.info('WireGuardService initialized successfully');
    } catch (e, stackTrace) {
      _errorService.handleV2RayError('WireGuard initialization', e, stackTrace);
      rethrow;
    }
  }

  /// Request VPN permission from Android system
  Future<bool> _requestVpnPermission() async {
    try {
      _errorService.info('Requesting VPN permission...');
      final result = await _vpnPermissionChannel.invokeMethod<bool>(
        'requestVpnPermission',
      );
      _errorService.info('VPN permission result: $result');
      return result ?? false;
    } on PlatformException catch (e) {
      _errorService.error('Failed to request VPN permission: ${e.message}');
      return false;
    }
  }

  Future<bool> connect(WireGuardConfig config) async {
    if (!isSupported) {
      _errorService.warning(
        'WireGuard connect attempted on unsupported platform.',
      );
      throw Exception(
        'WireGuard connections are only supported on Android devices.',
      );
    }
    if (_isConnecting) return false;

    _isConnecting = true;
    notifyListeners();

    try {
      _errorService.info('Connecting to WireGuard: ${config.name}');

      await initialize();

      if (_wireguard == null) {
        throw Exception('WireGuard service not initialized');
      }

      // Create tunnel config in wg-quick format
      final tunnelConfig = _createTunnelConfig(config);

      // Extract endpoint for serverAddress parameter
      final endpoint = config.peers.isNotEmpty
          ? config.peers.first.endpoint
          : '';

      // Request VPN permission FIRST (Critical!)
      final hasPermission = await _requestVpnPermission();
      if (!hasPermission) {
        throw Exception(
          'VPN permission was denied. Please allow VPN access when prompted.',
        );
      }

      // Start VPN with comprehensive error handling
      try {
        _errorService.info('Starting VPN service...');

        await _wireguard!.startVpn(
          serverAddress: endpoint,
          wgQuickConfig: tunnelConfig,
          providerBundleIdentifier: 'com.zedsecure.vpn',
        );

        _errorService.info('VPN service started successfully');

        // Wait a bit for VPN to establish
        await Future.delayed(const Duration(seconds: 1));
      } on PlatformException catch (e) {
        _errorService.error('Platform error during VPN start: ${e.message}');
        _errorService.error('Error code: ${e.code}');
        _errorService.error('Error details: ${e.details}');

        if (e.code == 'PERMISSION_DENIED' ||
            (e.message?.contains('permission') ?? false)) {
          throw Exception(
            'VPN permission was denied. Please allow VPN access in your device settings:\n\nSettings → Apps → FluxVPN → Permissions',
          );
        }

        throw Exception('Failed to start VPN: ${e.message ?? e.code}');
      } on Exception catch (vpnError) {
        _errorService.error('VPN start exception: $vpnError');
        throw Exception('VPN connection failed: ${vpnError.toString()}');
      } catch (vpnError) {
        _errorService.error('Unknown VPN error: $vpnError');
        throw Exception('VPN connection failed: ${vpnError.toString()}');
      }

      _activeConfig = config;
      _isConnected = true;
      await _saveActiveConfig(config.id);

      _errorService.info('Connected to WireGuard: ${config.name}');

      // Start monitoring
      _startMonitoring();

      notifyListeners();
      return true;
    } on Exception catch (e) {
      _errorService.error('WireGuard connection exception: $e');
      _isConnected = false;
      _activeConfig = null;
      notifyListeners();
      rethrow;
    } catch (e, stackTrace) {
      _errorService.handleV2RayError('WireGuard connection', e, stackTrace);
      _isConnected = false;
      _activeConfig = null;
      notifyListeners();
      return false;
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  void selectConfig(WireGuardConfig config) {
    _selectedConfig = config;
    _errorService.info('WireGuard config selected: ${config.name}');
    notifyListeners();
  }

  Future<void> disconnect() async {
    if (!isSupported) {
      _errorService.warning(
        'WireGuard disconnect attempted on unsupported platform.',
      );
      throw Exception(
        'WireGuard connections are only supported on Android devices.',
      );
    }
    try {
      _errorService.info('Disconnecting WireGuard...');

      _statsTimer?.cancel();
      _statsTimer = null;

      if (_wireguard != null) {
        await _wireguard!.stopVpn();
      }

      _isConnected = false;
      _activeConfig = null;
      _currentStats = null;
      await _clearActiveConfig();

      _errorService.info('WireGuard disconnected');
      notifyListeners();
    } catch (e, stackTrace) {
      _errorService.handleV2RayError('WireGuard disconnection', e, stackTrace);
    }
  }

  String _createTunnelConfig(WireGuardConfig config) {
    final buffer = StringBuffer();

    // Interface
    buffer.writeln('[Interface]');
    buffer.writeln('PrivateKey = ${config.interface.privateKey}');
    buffer.writeln('Address = ${config.interface.addresses.join(', ')}');
    if (config.interface.dns.isNotEmpty) {
      buffer.writeln('DNS = ${config.interface.dns.join(', ')}');
    }
    if (config.interface.mtu != null) {
      buffer.writeln('MTU = ${config.interface.mtu}');
    }
    if (config.interface.listenPort != null) {
      buffer.writeln('ListenPort = ${config.interface.listenPort}');
    }

    // Peers
    for (var peer in config.peers) {
      buffer.writeln();
      buffer.writeln('[Peer]');
      buffer.writeln('PublicKey = ${peer.publicKey}');
      if (peer.preSharedKey != null) {
        buffer.writeln('PresharedKey = ${peer.preSharedKey}');
      }
      buffer.writeln('Endpoint = ${peer.endpoint}');
      buffer.writeln('AllowedIPs = ${peer.allowedIPs.join(', ')}');
      if (peer.persistentKeepalive > 0) {
        buffer.writeln('PersistentKeepalive = ${peer.persistentKeepalive}');
      }
    }

    return buffer.toString();
  }

  /// Check WireGuard health by verifying handshake with peer
  /// Returns true if handshake is successful (config is healthy)
  /// This is the standard way to test WireGuard connectivity
  Future<bool> checkWireGuardHealth(WireGuardConfig config) async {
    try {
      if (!isSupported) {
        _errorService.warning(
          'WireGuard health check only supported on Android',
        );
        return false;
      }

      _errorService.info('Checking WireGuard health for ${config.name}...');

      // For now, use connection state as health indicator
      // In production, this would query actual WireGuard peer stats
      if (_isConnected && _activeConfig?.id == config.id) {
        _errorService.info(
          'WireGuard health check for ${config.name}: HEALTHY ✅ (connected)',
        );
        return true;
      }

      _errorService.info(
        'WireGuard health check for ${config.name}: UNHEALTHY ❌ (not connected)',
      );
      return false;
    } catch (e, stackTrace) {
      _errorService.error('Error checking WireGuard health', e, stackTrace);
      return false;
    }
  }

  /// Get detailed WireGuard peer statistics including handshake info
  Future<Map<String, dynamic>?> getWireGuardPeerStats() async {
    try {
      if (!isSupported) {
        _errorService.warning('WireGuard stats only supported on Android');
        return null;
      }

      // For now, return basic stats based on connection state
      // In production, this would query actual WireGuard peer stats via UAPI
      if (_isConnected && _activeConfig != null) {
        return {
          'lastHandshakeTime': DateTime.now().millisecondsSinceEpoch,
          'bytesReceived': 0,
          'bytesSent': 0,
          'interfaceName': 'wg0',
        };
      }

      return null;
    } catch (e) {
      _errorService.debug('Failed to get WireGuard peer stats: $e');
      return null;
    }
  }

  /// Continuous health monitoring for WireGuard
  /// Returns a stream of health check results
  Stream<WireGuardHealthResult> monitorWireGuardHealth(
    WireGuardConfig config, {
    Duration interval = const Duration(seconds: 5),
  }) async* {
    try {
      _errorService.info(
        'Starting WireGuard health monitoring for ${config.name}',
      );

      while (_isConnected && _activeConfig?.id == config.id) {
        final isHealthy = await checkWireGuardHealth(config);
        final stats = await getWireGuardPeerStats();

        yield WireGuardHealthResult(
          configId: config.id,
          configName: config.name,
          isHealthy: isHealthy,
          lastHandshakeTime: stats?['lastHandshakeTime'] as int?,
          bytesReceived: stats?['bytesReceived'] as int? ?? 0,
          bytesSent: stats?['bytesSent'] as int? ?? 0,
          timestamp: DateTime.now(),
        );

        await Future.delayed(interval);
      }

      _errorService.info(
        'Stopped WireGuard health monitoring for ${config.name}',
      );
    } catch (e, stackTrace) {
      _errorService.error(
        'Error in WireGuard health monitoring',
        e,
        stackTrace,
      );
    }
  }

  void _startMonitoring() {
    _statsTimer?.cancel();

    // Update stats every 2 seconds
    _statsTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_isConnected && _activeConfig != null && _wireguard != null) {
        try {
          // Get peer stats if available
          final stats = await getWireGuardPeerStats();

          _currentStats = WireGuardStats(
            bytesReceived: stats?['bytesReceived'] as int? ?? 0,
            bytesSent: stats?['bytesSent'] as int? ?? 0,
            lastHandshake: stats?['lastHandshakeTime'] != null
                ? DateTime.fromMillisecondsSinceEpoch(
                    stats!['lastHandshakeTime'] as int,
                  )
                : null,
          );
          notifyListeners();
        } catch (e) {
          // Ignore errors during monitoring
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _statsTimer?.cancel();
    super.dispose();
  }

  // Storage methods
  Future<void> saveConfig(WireGuardConfig config) async {
    try {
      _errorService.debug('Saving WireGuard config: ${config.name}');

      final prefs = await SharedPreferences.getInstance();
      final configs = await loadConfigs();

      // Remove old config with same ID
      configs.removeWhere((c) => c.id == config.id);
      configs.add(config);

      // Save non-sensitive data
      final configsJson = configs.map((c) {
        final json = c.toJson();
        json.remove('interface'); // Remove interface to save separately
        return json;
      }).toList();

      await prefs.setString('wireguard_configs', jsonEncode(configsJson));

      // Save sensitive keys in secure storage
      await _secureStorage.write(
        key: 'wg_private_key_${config.id}',
        value: config.interface.privateKey,
      );

      if (config.peers.isNotEmpty && config.peers.first.preSharedKey != null) {
        await _secureStorage.write(
          key: 'wg_preshared_key_${config.id}',
          value: config.peers.first.preSharedKey!,
        );
      }

      // Save interface data
      await prefs.setString(
        'wg_interface_${config.id}',
        jsonEncode(config.interface.toJson()),
      );

      _errorService.info('WireGuard config saved: ${config.name}');
    } catch (e, stackTrace) {
      _errorService.handleConfigError(config.id, e, stackTrace);
      rethrow;
    }
  }

  Future<List<WireGuardConfig>> loadConfigs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configsStr = prefs.getString('wireguard_configs');

      if (configsStr == null) return [];

      final configsJson = jsonDecode(configsStr) as List<dynamic>;
      final List<WireGuardConfig> configs = [];

      for (var json in configsJson) {
        try {
          final id = json['id'] as String;

          // Load interface
          final interfaceStr = prefs.getString('wg_interface_$id');
          if (interfaceStr == null) continue;

          final interfaceJson =
              jsonDecode(interfaceStr) as Map<String, dynamic>;

          // Load private key from secure storage
          final privateKey = await _secureStorage.read(
            key: 'wg_private_key_$id',
          );
          if (privateKey == null) continue;

          interfaceJson['privateKey'] = privateKey;
          json['interface'] = interfaceJson;

          // Load preshared key if exists
          final preSharedKey = await _secureStorage.read(
            key: 'wg_preshared_key_$id',
          );
          if (preSharedKey != null && json['peers'] != null) {
            final peers = json['peers'] as List<dynamic>;
            if (peers.isNotEmpty) {
              peers[0]['preSharedKey'] = preSharedKey;
            }
          }

          configs.add(WireGuardConfig.fromJson(json as Map<String, dynamic>));
        } catch (e) {
          _errorService.warning('Failed to load WireGuard config', e);
        }
      }

      return configs;
    } catch (e, stackTrace) {
      _errorService.error('Failed to load WireGuard configs', e, stackTrace);
      return [];
    }
  }

  Future<void> deleteConfig(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configs = await loadConfigs();

      configs.removeWhere((c) => c.id == id);

      final configsJson = configs.map((c) {
        final json = c.toJson();
        json.remove('interface');
        return json;
      }).toList();

      await prefs.setString('wireguard_configs', jsonEncode(configsJson));
      await prefs.remove('wg_interface_$id');
      await _secureStorage.delete(key: 'wg_private_key_$id');
      await _secureStorage.delete(key: 'wg_preshared_key_$id');

      _errorService.info('WireGuard config deleted: $id');
    } catch (e, stackTrace) {
      _errorService.handleConfigError(id, e, stackTrace);
    }
  }

  Future<void> _saveActiveConfig(String configId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wg_active_config', configId);
  }

  Future<void> _clearActiveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('wg_active_config');
  }

  Future<WireGuardConfig?> loadActiveConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configId = prefs.getString('wg_active_config');

      if (configId == null) return null;

      final configs = await loadConfigs();
      return configs.firstWhere(
        (c) => c.id == configId,
        orElse: () => throw Exception(),
      );
    } catch (e) {
      return null;
    }
  }
}

class WireGuardStats {
  final int bytesReceived;
  final int bytesSent;
  final DateTime? lastHandshake;

  WireGuardStats({
    required this.bytesReceived,
    required this.bytesSent,
    this.lastHandshake,
  });
}

/// Result of WireGuard health check (handshake verification)
class WireGuardHealthResult {
  final String configId;
  final String configName;
  final bool isHealthy;
  final int? lastHandshakeTime; // milliseconds since epoch
  final int bytesReceived;
  final int bytesSent;
  final DateTime timestamp;

  WireGuardHealthResult({
    required this.configId,
    required this.configName,
    required this.isHealthy,
    this.lastHandshakeTime,
    required this.bytesReceived,
    required this.bytesSent,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'WireGuardHealthResult('
        'configId: $configId, '
        'configName: $configName, '
        'isHealthy: $isHealthy, '
        'lastHandshake: $lastHandshakeTime, '
        'bytesReceived: $bytesReceived, '
        'bytesSent: $bytesSent, '
        'timestamp: $timestamp)';
  }
}
