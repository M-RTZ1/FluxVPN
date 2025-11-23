import 'dart:async';
import 'package:flutter/services.dart';
import 'package:fluxvpn/services/error_service.dart';

class PingResult {
  final bool success;
  final int latency;
  final String method;
  final String? error;
  final int timestamp;

  const PingResult({
    required this.success,
    required this.latency,
    required this.method,
    this.error,
    required this.timestamp,
  });

  factory PingResult.fromMap(Map<String, dynamic> map) {
    return PingResult(
      success: map['success'] ?? false,
      latency: (map['latency'] ?? -1) as int,
      method: map['method'] ?? 'unknown',
      error: map['error'],
      timestamp: (map['timestamp'] ?? 0) as int,
    );
  }

  factory PingResult.error(String errorMessage) {
    return PingResult(
      success: false,
      latency: -1,
      method: 'error',
      error: errorMessage,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  String toString() {
    if (success) {
      return 'PingResult(success: $success, latency: ${latency}ms, method: $method)';
    } else {
      return 'PingResult(success: $success, error: $error, method: $method)';
    }
  }
}

class NativePingService {
  static const MethodChannel _channel = MethodChannel('com.zedsecure.vpn/ping');

  static final Map<String, PingResult> _pingCache = {};
  static final Map<String, bool> _pingInProgress = {};

  static final Map<String, StreamController<PingResult>>
      _continuousPingControllers = {};

  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _channel.setMethodCallHandler(_handleMethodCall);
      _isInitialized = true;
      ErrorService().info('NativePingService initialized successfully');
    } catch (e) {
      ErrorService().error('Error initializing NativePingService: $e');
    }
  }

  static Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onContinuousPingResult') {
      try {
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          call.arguments,
        );
        final String pingId = data['pingId'];
        final Map<String, dynamic> resultMap = Map<String, dynamic>.from(
          data['result'],
        );
        final PingResult result = PingResult.fromMap(resultMap);

        final controller = _continuousPingControllers[pingId];
        if (controller != null && !controller.isClosed) {
          controller.add(result);
        }
      } catch (e) {
        ErrorService().error('Error handling continuous ping result: $e');
      }
    }
  }

  static Future<PingResult> pingHost({
    required String host,
    int port = 80,
    int timeoutMs = 5000,
    bool useIcmp = true,
    bool useTcp = true,
    bool useCache = true,
  }) async {
    try {
      await initialize();

      final String cacheKey = '$host:$port';

      if (useCache && _pingCache.containsKey(cacheKey)) {
        final cachedResult = _pingCache[cacheKey]!;
        final ageMs =
            DateTime.now().millisecondsSinceEpoch - cachedResult.timestamp;
        if (ageMs < 30000) {
          return cachedResult;
        }
      }

      if (_pingInProgress[cacheKey] == true) {
        int attempts = 0;
        while (_pingInProgress[cacheKey] == true && attempts < 50) {
          await Future.delayed(const Duration(milliseconds: 200));
          attempts++;
        }

        if (_pingCache.containsKey(cacheKey)) {
          return _pingCache[cacheKey]!;
        }
      }

      _pingInProgress[cacheKey] = true;

      try {
        final Map<String, dynamic> arguments = {
          'host': host,
          'port': port,
          'timeoutMs': timeoutMs,
          'useIcmp': useIcmp,
          'useTcp': useTcp,
        };

        final Map<String, dynamic>? result = await _channel.invokeMapMethod(
          'pingHost',
          arguments,
        );

        if (result != null) {
          final pingResult = PingResult.fromMap(result);

          if (useCache) {
            _pingCache[cacheKey] = pingResult;
          }

          return pingResult;
        } else {
          return PingResult.error('No result received from native ping');
        }
      } finally {
        _pingInProgress[cacheKey] = false;
      }
    } catch (e) {
      ErrorService().error('Error in pingHost: $e');
      _pingInProgress['$host:$port'] = false;
      return PingResult.error('Ping failed: ${e.toString()}');
    }
  }

  static Future<Map<String, PingResult>> pingMultipleHosts({
    required List<({String host, int port})> hosts,
    int timeoutMs = 5000,
    bool useIcmp = true,
    bool useTcp = true,
  }) async {
    try {
      await initialize();

      final List<Map<String, dynamic>> hostMaps = hosts
          .map((hostInfo) => {'host': hostInfo.host, 'port': hostInfo.port})
          .toList();

      final Map<String, dynamic> arguments = {
        'hosts': hostMaps,
        'timeoutMs': timeoutMs,
        'useIcmp': useIcmp,
        'useTcp': useTcp,
      };

      final Map<String, dynamic>? result = await _channel.invokeMapMethod(
        'pingMultipleHosts',
        arguments,
      );

      if (result != null) {
        final Map<String, PingResult> pingResults = {};

        result.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            pingResults[key] = PingResult.fromMap(value);
          }
        });

        return pingResults;
      } else {
        return {};
      }
    } catch (e) {
      ErrorService().error('Error in pingMultipleHosts: $e');
      return {};
    }
  }

  static Stream<PingResult> startContinuousPing({
    required String host,
    int port = 80,
    Duration interval = const Duration(seconds: 5),
  }) {
    final String pingId =
        '${host}_${port}_${DateTime.now().millisecondsSinceEpoch}';

    final StreamController<PingResult> controller =
        StreamController<PingResult>.broadcast();
    _continuousPingControllers[pingId] = controller;

    _startNativeContinuousPing(pingId, host, port, interval);

    controller.onCancel = () {
      stopContinuousPing(pingId);
    };

    return controller.stream;
  }

  static Future<void> _startNativeContinuousPing(
    String pingId,
    String host,
    int port,
    Duration interval,
  ) async {
    try {
      await initialize();

      final Map<String, dynamic> arguments = {
        'pingId': pingId,
        'host': host,
        'port': port,
        'intervalMs': interval.inMilliseconds,
      };

      await _channel.invokeMethod('startContinuousPing', arguments);
    } catch (e) {
      ErrorService().error('Error starting continuous ping: $e');

      final controller = _continuousPingControllers[pingId];
      if (controller != null && !controller.isClosed) {
        controller.add(PingResult.error('Failed to start continuous ping: $e'));
      }
    }
  }

  static Future<void> stopContinuousPing(String pingId) async {
    try {
      await _channel.invokeMethod('stopContinuousPing', {'pingId': pingId});

      final controller = _continuousPingControllers[pingId];
      if (controller != null) {
        await controller.close();
        _continuousPingControllers.remove(pingId);
      }
    } catch (e) {
      ErrorService().error('Error stopping continuous ping: $e');
    }
  }

  static Future<void> stopAllContinuousPings() async {
    final List<String> pingIds = List.from(_continuousPingControllers.keys);

    for (final pingId in pingIds) {
      await stopContinuousPing(pingId);
    }
  }

  static Future<String> getNetworkType() async {
    try {
      await initialize();
      final String? networkType = await _channel.invokeMethod('getNetworkType');
      return networkType ?? 'Unknown';
    } catch (e) {
      ErrorService().error('Error getting network type: $e');
      return 'Unknown';
    }
  }

  static void clearCache({String? host, int? port}) {
    if (host != null && port != null) {
      _pingCache.remove('$host:$port');
    } else {
      _pingCache.clear();
    }
  }

  static PingResult? getCachedPing(String host, int port) {
    return _pingCache['$host:$port'];
  }

  static bool isPingInProgress(String host, int port) {
    return _pingInProgress['$host:$port'] == true;
  }

  static Map<String, dynamic> getCacheStats() {
    final now = DateTime.now().millisecondsSinceEpoch;
    int validEntries = 0;
    int expiredEntries = 0;

    for (final result in _pingCache.values) {
      final ageMs = now - result.timestamp;
      if (ageMs < 30000) {
        validEntries++;
      } else {
        expiredEntries++;
      }
    }

    return {
      'totalEntries': _pingCache.length,
      'validEntries': validEntries,
      'expiredEntries': expiredEntries,
      'inProgressCount': _pingInProgress.values.where((v) => v).length,
    };
  }

  static Future<void> cleanup() async {
    try {
      await stopAllContinuousPings();
      await _channel.invokeMethod('cleanup');
      _pingCache.clear();
      _pingInProgress.clear();
      _isInitialized = false;
    } catch (e) {
      ErrorService().error('Error during cleanup: $e');
    }
  }

  static Future<Map<String, PingResult>> testConnectivity() async {
    final testHosts = [
      (host: 'google.com', port: 80),
      (host: 'cloudflare.com', port: 80),
      (host: '1.1.1.1', port: 53),
      (host: '8.8.8.8', port: 53),
    ];

    return await pingMultipleHosts(hosts: testHosts, timeoutMs: 3000);
  }
}
