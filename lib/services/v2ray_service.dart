import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluxvpn/models/v2ray_config.dart';
import 'package:fluxvpn/models/subscription.dart';
import 'package:fluxvpn/services/error_service.dart';
import 'package:fluxvpn/utils/semaphore.dart';
import 'package:flutter/foundation.dart';

/// Cache entry for ping results with timestamp
class _PingCacheEntry {
  final int latency;
  final int timestamp; // milliseconds since epoch
  static const int defaultExpiryMs = 30000; // 30 seconds

  _PingCacheEntry({
    required this.latency,
    required this.timestamp,
  });

  /// Check if cache entry is still valid
  bool isValid() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - timestamp) < defaultExpiryMs;
  }

  /// Get age of cache entry in milliseconds
  int getAgeMs() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return now - timestamp;
  }
}

/// Continuous ping result with metadata
class ContinuousPingResult {
  final String configId;
  final int latency;
  final int timestamp;
  final bool success;
  final String? error;
  final String method; // 'V2Ray', 'TCP', etc.

  ContinuousPingResult({
    required this.configId,
    required this.latency,
    required this.timestamp,
    required this.success,
    this.error,
    required this.method,
  });

  @override
  String toString() {
    if (success) {
      return 'ContinuousPingResult(configId: $configId, latency: ${latency}ms, method: $method)';
    } else {
      return 'ContinuousPingResult(configId: $configId, error: $error, method: $method)';
    }
  }
}

class V2RayService extends ChangeNotifier {
  bool _isInitialized = false;
  V2RayConfig? _activeConfig;
  V2RayStatus? _currentStatus;
  
  final Map<String, _PingCacheEntry> _pingCache = {}; // Changed to store cache entries
  final Map<String, bool> _pingInProgress = {};
  final ErrorService _errorService = ErrorService();
  final Semaphore _pingSemaphore = Semaphore(3); // Max 3 concurrent pings
  
  // Continuous ping management
  final Map<String, StreamController<ContinuousPingResult>> _continuousPingControllers = {};
  final Map<String, bool> _continuousPingActive = {};
  
  // Multiple test endpoints for better reliability
  static const List<String> _testEndpoints = [
    'https://www.gstatic.com/generate_204',
    'https://connectivitycheck.gstatic.com/generate_204',
    'https://cp.cloudflare.com/generate_204',
  ];

  static final V2RayService _instance = V2RayService._internal();
  factory V2RayService() => _instance;

  late final V2ray _flutterV2ray;
  
  List<String> _customDnsServers = ['1.1.1.1', '1.0.0.1'];
  bool _useDns = true;
  String? _detectedCountryCode;

  V2RayStatus? get currentStatus => _currentStatus;
  V2RayConfig? get activeConfig => _activeConfig;
  bool get isConnected => _activeConfig != null;

  V2RayService._internal() {
    _flutterV2ray = V2ray(
      onStatusChanged: (status) {
        _currentStatus = status;
        _handleStatusChange(status);
        notifyListeners();
      },
    );
  }

  void _handleStatusChange(V2RayStatus status) {
    String statusString = status.toString().toLowerCase();
    if ((statusString.contains('disconnect') ||
            statusString.contains('stop') ||
            statusString.contains('idle')) &&
        _activeConfig != null) {
      _activeConfig = null;
      _clearActiveConfig();
    }
  }

  Future<void> initialize() async {
    if (!_isInitialized) {
      try {
        _errorService.info('Initializing V2RayService...');
        await _flutterV2ray.initialize(
          notificationIconResourceType: "mipmap",
          notificationIconResourceName: "ic_launcher",
        );
        _isInitialized = true;
        await _loadDnsSettings();
        await _tryRestoreActiveConfig();
        _errorService.info('V2RayService initialized successfully');
      } catch (e, stackTrace) {
        _errorService.handleV2RayError('initialization', e, stackTrace);
        rethrow;
      }
    }
  }
  
  Future<void> _loadDnsSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _useDns = prefs.getBool('use_custom_dns') ?? true;
    final dnsString = prefs.getString('custom_dns_servers');
    if (dnsString != null && dnsString.isNotEmpty) {
      _customDnsServers = dnsString.split(',');
    }
  }
  
  Future<void> saveDnsSettings(bool enabled, List<String> servers) async {
    _useDns = enabled;
    _customDnsServers = servers;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_custom_dns', enabled);
    await prefs.setString('custom_dns_servers', servers.join(','));
    notifyListeners();
  }
  
  bool get useDns => _useDns;
  List<String> get dnsServers => List.from(_customDnsServers);
  String? get detectedCountryCode => _detectedCountryCode;

  Future<String?> detectRealCountry() async {
    try {
      _errorService.debug('Detecting real country...');
      final response = await http.get(
        Uri.parse('https://ipapi.co/json/'),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final countryCode = data['country_code'] as String?;
        _detectedCountryCode = countryCode;
        _errorService.info('Country detected: $countryCode');
        notifyListeners();
        return countryCode;
      }
    } catch (e, stackTrace) {
      _errorService.handleNetworkError('country detection', e, stackTrace);
    }
    return null;
  }

  Future<bool> connect(V2RayConfig config) async {
    try {
      await initialize();

      V2RayURL parser = V2ray.parseFromURL(config.fullConfig);
      
      if (_useDns && _customDnsServers.isNotEmpty) {
        parser.dns = {
          'servers': _customDnsServers
        };
      }

      bool hasPermission = await _flutterV2ray.requestPermission();
      if (!hasPermission) {
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final blockedAppsList = prefs.getStringList('blocked_apps');

      await _flutterV2ray.startV2Ray(
        remark: parser.remark,
        config: parser.getFullConfiguration(),
        blockedApps: blockedAppsList,
        proxyOnly: false,
        notificationDisconnectButtonName: "DISCONNECT",
      );

      _activeConfig = config;
      await _saveActiveConfig(config);
      
      detectRealCountry();
      
      notifyListeners();

      return true;
    } catch (e) {
      _errorService.error('Error connecting to V2Ray: $e');
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await _flutterV2ray.stopV2Ray();
      _activeConfig = null;
      _detectedCountryCode = null;
      await _clearActiveConfig();
      notifyListeners();
    } catch (e) {
      _errorService.error('Error disconnecting from V2Ray: $e');
    }
  }

  Future<int?> getServerDelay(V2RayConfig config) async {
    final configId = config.id;
    final hostKey = '${config.address}:${config.port}';

    // Skip IPv6 addresses as they might not be supported on all devices
    if (config.address.contains(':') && !config.address.contains('::1')) {
      _errorService.debug('Skipping IPv6 address for ${config.remark}: ${config.address}');
      return null;
    }

    try {
      // Check cache with expiry
      if (_pingCache.containsKey(hostKey)) {
        final cachedEntry = _pingCache[hostKey];
        if (cachedEntry != null && cachedEntry.isValid()) {
          _errorService.debug('Returning cached ping for ${config.remark}: ${cachedEntry.latency}ms (age: ${cachedEntry.getAgeMs()}ms)');
          return cachedEntry.latency;
        }
      } else if (_pingCache.containsKey(configId)) {
        final cachedEntry = _pingCache[configId];
        if (cachedEntry != null && cachedEntry.isValid()) {
          _errorService.debug('Returning cached ping for ${config.remark}: ${cachedEntry.latency}ms (age: ${cachedEntry.getAgeMs()}ms)');
          return cachedEntry.latency;
        }
      }

      // If ping is already in progress, wait for it
      if (_pingInProgress[hostKey] == true || _pingInProgress[configId] == true) {
        int attempts = 0;
        while ((_pingInProgress[hostKey] == true || _pingInProgress[configId] == true) && attempts < 25) {
          await Future.delayed(const Duration(milliseconds: 200));
          attempts++;
        }
        // Return cached result if available
        final cachedEntry = _pingCache[hostKey] ?? _pingCache[configId];
        return cachedEntry?.latency;
      }

      _pingInProgress[hostKey] = true;
      _pingInProgress[configId] = true;

      try {
        await initialize();
        
        // Use semaphore to limit concurrent pings
        final delay = await _pingSemaphore.run(() async {
          _errorService.debug('Starting ping for ${config.remark} - ${config.address}:${config.port}');
          
          final parser = V2ray.parseFromURL(config.fullConfig);
          
          // Apply DNS settings for ping as well
          if (_useDns && _customDnsServers.isNotEmpty) {
            parser.dns = {
              'servers': _customDnsServers
            };
            _errorService.debug('Applied DNS servers for ping: $_customDnsServers');
          }
          
          final fullConfig = parser.getFullConfiguration();
          
          _errorService.debug('Config parsed successfully for ${config.remark}');
          _errorService.debug('Full config JSON: $fullConfig');
          
          // Try up to 2 times with exponential backoff + jitter
          int? result;
          for (int attempt = 0; attempt < 2; attempt++) {
            try {
              _errorService.debug('Ping attempt ${attempt + 1}/2 for ${config.remark}');
              
              // Try V2Ray ping first
              result = await _flutterV2ray
                  .getServerDelay(config: fullConfig)
                  .timeout(
                    Duration(seconds: 15 + (attempt * 5)), // 15s first, 20s second
                    onTimeout: () {
                      _errorService.debug('V2Ray ping timeout for ${config.remark} (attempt ${attempt + 1}/2)');
                      throw Exception('V2Ray ping timeout');
                    },
                  );
              
              // If successful, break the retry loop
              if (result >= 0 && result < 10000) {
                _errorService.debug('Ping successful for ${config.remark}: ${result}ms');
                break;
              } else if (result < 0) {
                _errorService.debug('Ping returned invalid result for ${config.remark}: ${result}ms');
                throw Exception('Invalid ping result: $result');
              }
            } catch (e) {
              _errorService.debug('V2Ray ping failed for ${config.remark}: $e');
              
              // Try fallback TCP ping if V2Ray fails
              if (attempt == 1) {
                _errorService.info('Attempting fallback TCP ping for ${config.remark}');
                result = await _tcpPing(config.address, config.port);
                
                if (result != null && result >= 0 && result < 10000) {
                  _errorService.info('Fallback TCP ping successful for ${config.remark}: ${result}ms');
                  break;
                } else {
                  _errorService.error('All ping attempts failed for ${config.remark}: $e');
                  rethrow;
                }
              }
              
              // Exponential backoff with jitter
              final baseDelay = 600 * (attempt + 1);
              final jitter = Random().nextInt(250);
              final waitTime = Duration(milliseconds: baseDelay + jitter);
              _errorService.debug('Retrying ${config.remark} after ${waitTime.inMilliseconds}ms...');
              await Future.delayed(waitTime);
            }
          }
          
          return result;
        });

        if (delay != null && delay >= 0 && delay < 10000) {
          // Store in cache with timestamp
          final cacheEntry = _PingCacheEntry(
            latency: delay,
            timestamp: DateTime.now().millisecondsSinceEpoch,
          );
          _pingCache[hostKey] = cacheEntry;
          _pingCache[configId] = cacheEntry;
          
          _errorService.debug('Cached ping for ${config.remark}: ${delay}ms');
          
          _pingInProgress[hostKey] = false;
          _pingInProgress[configId] = false;
          
          return delay;
        } else {
          _pingInProgress[hostKey] = false;
          _pingInProgress[configId] = false;
          _pingCache.remove(hostKey);
          _pingCache.remove(configId);
          return null;
        }
      } catch (e) {
        _errorService.error('Error with V2Ray ping for ${config.remark}: $e');
        _pingInProgress[hostKey] = false;
        _pingInProgress[configId] = false;
        _pingCache.remove(hostKey);
        _pingCache.remove(configId);
        return null;
      }
    } catch (e) {
      _errorService.error('Unexpected error in getServerDelay for ${config.remark}: $e');
      _pingInProgress[hostKey] = false;
      _pingInProgress[configId] = false;
      return null;
    }
  }

  // Alias for getServerDelay for better naming
  Future<int?> pingServer(V2RayConfig config) async {
    return await getServerDelay(config);
  }

  // Test ping without DNS (useful for debugging DNS issues)
  Future<int?> pingServerWithoutDns(V2RayConfig config) async {
    final originalUseDns = _useDns;
    try {
      _useDns = false;
      _errorService.info('Testing ping for ${config.remark} WITHOUT custom DNS');
      final result = await getServerDelay(config);
      return result;
    } finally {
      _useDns = originalUseDns;
    }
  }

  /// Fallback TCP ping when V2Ray fails
  /// This is a simple TCP connection test to the server
  Future<int?> _tcpPing(String host, int port) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      _errorService.debug('Attempting TCP ping to $host:$port');
      
      // Try to connect via TCP socket
      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 8),
      );
      
      stopwatch.stop();
      final latency = stopwatch.elapsedMilliseconds;
      
      // Close the socket
      await socket.close();
      
      _errorService.debug('TCP ping successful to $host:$port: ${latency}ms');
      return latency;
    } catch (e) {
      stopwatch.stop();
      _errorService.debug('TCP ping failed to $host:$port: $e');
      return null;
    }
  }

  /// Detect network type (WiFi, Mobile, Ethernet, etc.)
  /// This helps adjust timeout values based on network conditions
  Future<String> getNetworkType() async {
    try {
      final connectivityResult = await InternetAddress.lookup('google.com');
      
      if (connectivityResult.isNotEmpty && connectivityResult[0].rawAddress.isNotEmpty) {
        // For now, we'll return a generic "Connected" status
        // In a real app, you'd use the connectivity_plus package
        _errorService.debug('Network is connected');
        return 'Connected';
      }
      
      return 'Disconnected';
    } catch (e) {
      _errorService.debug('Error detecting network type: $e');
      return 'Unknown';
    }
  }

  /// Connectivity test - ping multiple common endpoints
  /// Useful for diagnosing network issues
  Future<Map<String, bool>> testConnectivity() async {
    final results = <String, bool>{};
    final testHosts = [
      'google.com',
      'cloudflare.com',
      '1.1.1.1',
      '8.8.8.8',
    ];

    _errorService.info('Starting connectivity test...');
    
    for (final host in testHosts) {
      try {
        final result = await InternetAddress.lookup(host);
        results[host] = result.isNotEmpty;
        _errorService.debug('Connectivity test for $host: ${results[host]}');
      } catch (e) {
        results[host] = false;
        _errorService.debug('Connectivity test for $host failed: $e');
      }
    }

    _errorService.info('Connectivity test complete: $results');
    return results;
  }

  /// Start continuous ping monitoring for a server
  /// Returns a stream of ping results at regular intervals
  Stream<ContinuousPingResult> startContinuousPing(
    V2RayConfig config, {
    Duration interval = const Duration(seconds: 5),
  }) {
    final configId = config.id;
    
    // Create stream controller if not exists
    if (!_continuousPingControllers.containsKey(configId)) {
      _continuousPingControllers[configId] = StreamController<ContinuousPingResult>.broadcast();
    }
    
    final controller = _continuousPingControllers[configId]!;
    _continuousPingActive[configId] = true;
    
    _errorService.info('Starting continuous ping for ${config.remark}');
    
    // Start periodic ping in background
    _startContinuousPingLoop(config, interval);
    
    // Clean up when stream is cancelled
    controller.onCancel = () {
      stopContinuousPing(configId);
    };
    
    return controller.stream;
  }

  /// Internal method to run continuous ping loop
  void _startContinuousPingLoop(
    V2RayConfig config,
    Duration interval,
  ) async {
    final configId = config.id;
    
    while (_continuousPingActive[configId] == true) {
      try {
        // Get ping result
        final latency = await getServerDelay(config);
        
        // Create result
        final result = ContinuousPingResult(
          configId: configId,
          latency: latency ?? -1,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          success: latency != null && latency >= 0,
          error: latency == null ? 'Ping failed' : null,
          method: 'V2Ray',
        );
        
        // Send to stream
        final controller = _continuousPingControllers[configId];
        if (controller != null && !controller.isClosed) {
          controller.add(result);
          _errorService.debug('Continuous ping result: $result');
        }
        
        // Wait for next interval
        await Future.delayed(interval);
      } catch (e) {
        _errorService.error('Error in continuous ping loop: $e');
        
        // Send error result
        final controller = _continuousPingControllers[configId];
        if (controller != null && !controller.isClosed) {
          controller.add(ContinuousPingResult(
            configId: configId,
            latency: -1,
            timestamp: DateTime.now().millisecondsSinceEpoch,
            success: false,
            error: e.toString(),
            method: 'V2Ray',
          ));
        }
        
        // Wait before retrying
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  /// Stop continuous ping for a specific config
  Future<void> stopContinuousPing(String configId) async {
    _continuousPingActive[configId] = false;
    
    final controller = _continuousPingControllers[configId];
    if (controller != null && !controller.isClosed) {
      await controller.close();
      _continuousPingControllers.remove(configId);
    }
    
    _errorService.info('Stopped continuous ping for $configId');
  }

  /// Stop all continuous pings
  Future<void> stopAllContinuousPings() async {
    final configIds = List<String>.from(_continuousPingActive.keys);
    
    for (final configId in configIds) {
      await stopContinuousPing(configId);
    }
    
    _errorService.info('Stopped all continuous pings');
  }

  /// Check if continuous ping is active for a config
  bool isContinuousPingActive(String configId) {
    return _continuousPingActive[configId] == true;
  }

  void clearPingCache({String? configId}) {
    if (configId != null) {
      _pingCache.remove(configId);
    } else {
      _pingCache.clear();
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    int validEntries = 0;
    int expiredEntries = 0;

    for (final entry in _pingCache.values) {
      if (entry.isValid()) {
        validEntries++;
      } else {
        expiredEntries++;
      }
    }

    return {
      'totalEntries': _pingCache.length,
      'validEntries': validEntries,
      'expiredEntries': expiredEntries,
      'cacheExpiryMs': _PingCacheEntry.defaultExpiryMs,
    };
  }

  /// Log cache statistics to debug
  void logCacheStats() {
    final stats = getCacheStats();
    _errorService.debug('=== PING CACHE STATS ===');
    _errorService.debug('Total Entries: ${stats['totalEntries']}');
    _errorService.debug('Valid Entries: ${stats['validEntries']}');
    _errorService.debug('Expired Entries: ${stats['expiredEntries']}');
    _errorService.debug('Cache Expiry: ${stats['cacheExpiryMs']}ms');
    _errorService.debug('=== END CACHE STATS ===');
  }

  // Diagnostic method to log DNS and config information
  Future<void> logDiagnosticInfo(V2RayConfig config) async {
    _errorService.info('=== DIAGNOSTIC INFO FOR ${config.remark} ===');
    _errorService.info('DNS Enabled: $_useDns');
    _errorService.info('DNS Servers: $_customDnsServers');
    _errorService.info('Config Address: ${config.address}:${config.port}');
    _errorService.info('Config Type: ${config.configType}');
    
    try {
      final parser = V2ray.parseFromURL(config.fullConfig);
      if (_useDns && _customDnsServers.isNotEmpty) {
        parser.dns = {
          'servers': _customDnsServers
        };
      }
      final fullConfig = parser.getFullConfiguration();
      _errorService.info('Generated Config JSON: $fullConfig');
    } catch (e) {
      _errorService.error('Error generating config: $e');
    }
    _errorService.info('=== END DIAGNOSTIC INFO ===');
  }

  Future<List<V2RayConfig>> parseSubscriptionUrl(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw Exception('Network timeout: Check your internet connection');
            },
          );

      if (response.statusCode != 200) {
        throw Exception('Failed to load subscription: HTTP ${response.statusCode}');
      }

      return _parseContent(response.body, source: 'subscription');
    } catch (e) {
      _errorService.error('Error parsing subscription: $e');
      
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Network is unreachable')) {
        throw Exception('Network error: Check your internet connection');
      } else if (e.toString().contains('timeout')) {
        throw Exception('Connection timeout: Server is not responding');
      } else if (e.toString().contains('Invalid URL')) {
        throw Exception('Invalid subscription URL format');
      } else if (e.toString().contains('No valid configurations')) {
        throw Exception('No valid servers found in subscription');
      } else {
        throw Exception('Failed to update subscription: ${e.toString()}');
      }
    }
  }

  Future<List<V2RayConfig>> parseSubscriptionContent(String content) async {
    try {
      return _parseContent(content, source: 'subscription');
    } catch (e) {
      _errorService.error('Error parsing subscription content: $e');
      
      if (e.toString().contains('No valid configurations')) {
        throw Exception('No valid servers found in file');
      } else {
        throw Exception('Failed to parse subscription file: ${e.toString()}');
      }
    }
  }

  Future<V2RayConfig?> parseConfigFromClipboard(String clipboardText) async {
    try {
      final configs = _parseContent(clipboardText, source: 'manual');
      if (configs.isNotEmpty) {
        final allConfigs = await loadConfigs();
        allConfigs.add(configs.first);
        await saveConfigs(allConfigs);
        return configs.first;
      }
      return null;
    } catch (e) {
      _errorService.error('Error parsing clipboard config: $e');
      throw Exception('Invalid config format');
    }
  }

  List<V2RayConfig> _parseContent(String content, {String source = 'subscription'}) {
    final List<V2RayConfig> configs = [];

    try {
      if (_isBase64(content)) {
        final decoded = utf8.decode(base64.decode(content.trim()));
        content = decoded;
      }
    } catch (e) {
      _errorService.debug('Not a valid base64 content, using original: $e');
    }

    final List<String> lines = content.split('\n');

    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      try {
        if (line.startsWith('vmess://') ||
            line.startsWith('vless://') ||
            line.startsWith('trojan://') ||
            line.startsWith('ss://')) {
          V2RayURL parser = V2ray.parseFromURL(line);
          String configType = '';

          if (line.startsWith('vmess://')) {
            configType = 'vmess';
          } else if (line.startsWith('vless://')) {
            configType = 'vless';
          } else if (line.startsWith('ss://')) {
            configType = 'shadowsocks';
          } else if (line.startsWith('trojan://')) {
            configType = 'trojan';
          }

          String address = parser.address;
          int port = parser.port;

          configs.add(
            V2RayConfig(
              id: DateTime.now().millisecondsSinceEpoch.toString() + configs.length.toString(),
              remark: parser.remark,
              address: address,
              port: port,
              configType: configType,
              fullConfig: line,
              source: source,
            ),
          );
        }
      } catch (e) {
        _errorService.error('Error parsing config: $e');
      }
    }

    if (configs.isEmpty) {
      throw Exception('No valid configurations found in subscription');
    }

    return configs;
  }

  bool _isBase64(String str) {
    str = str.trim();
    if (str.length % 4 != 0) {
      return false;
    }
    return RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(str);
  }

  Future<void> saveConfigs(List<V2RayConfig> configs) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> configsJson = configs
        .map((config) => jsonEncode(config.toJson()))
        .toList();
    await prefs.setStringList('v2ray_configs', configsJson);
  }

  Future<List<V2RayConfig>> loadConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? configsJson = prefs.getStringList('v2ray_configs');
    if (configsJson == null) return [];

    return configsJson
        .map((json) => V2RayConfig.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> saveSubscriptions(List<Subscription> subscriptions) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> subscriptionsJson = subscriptions
        .map((sub) => jsonEncode(sub.toJson()))
        .toList();
    await prefs.setStringList('v2ray_subscriptions', subscriptionsJson);
  }

  Future<List<Subscription>> loadSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? subscriptionsJson = prefs.getStringList('v2ray_subscriptions');
    if (subscriptionsJson == null) return [];

    return subscriptionsJson
        .map((json) => Subscription.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> _saveActiveConfig(V2RayConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_config', jsonEncode(config.toJson()));
  }

  Future<void> _clearActiveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_config');
  }

  Future<V2RayConfig?> _loadActiveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final String? configJson = prefs.getString('active_config');
    if (configJson == null) return null;
    return V2RayConfig.fromJson(jsonDecode(configJson));
  }

  Future<void> saveSelectedConfig(V2RayConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_config', jsonEncode(config.toJson()));
  }

  Future<V2RayConfig?> loadSelectedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final String? configJson = prefs.getString('selected_config');
    if (configJson == null) return null;
    return V2RayConfig.fromJson(jsonDecode(configJson));
  }

  Future<void> _tryRestoreActiveConfig() async {
    try {
      final delay = await _flutterV2ray.getConnectedServerDelay();
      final isConnected = delay >= 0;

      if (isConnected) {
        final savedConfig = await _loadActiveConfig();
        if (savedConfig != null) {
          _activeConfig = savedConfig;
          _errorService.debug('Restored active config: ${savedConfig.remark}');
          notifyListeners();
        }
      } else {
        await _clearActiveConfig();
        _activeConfig = null;
        notifyListeners();
      }
    } catch (e) {
      _errorService.error('Error restoring active config: $e');
      await _clearActiveConfig();
      _activeConfig = null;
      notifyListeners();
    }
  }

  // Favorites Management
  Future<void> toggleFavorite(V2RayConfig config) async {
    final configs = await loadConfigs();
    final index = configs.indexWhere((c) => c.id == config.id);
    
    if (index != -1) {
      configs[index].isFavorite = !configs[index].isFavorite;
      await saveConfigs(configs);
      notifyListeners();
    }
  }

  Future<List<V2RayConfig>> loadFavoriteConfigs() async {
    final configs = await loadConfigs();
    return configs.where((config) => config.isFavorite).toList();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
