/// Speed optimization settings for V2Ray
class SpeedOptimization {
  /// Enable Mux (Multiplexing) for better performance
  final bool muxEnabled;
  
  /// Number of concurrent connections in Mux (4-16 optimal)
  final int muxConcurrency;
  
  /// Buffer size in KB (512-2048 for high speed)
  final int bufferSize;
  
  /// TCP congestion control algorithm (bbr, cubic, reno)
  final String tcpCongestion;
  
  /// Enable TCP Fast Open to reduce latency
  final bool tcpFastOpen;
  
  /// DNS query strategy
  final String dnsStrategy;

  const SpeedOptimization({
    this.muxEnabled = true,
    this.muxConcurrency = 8,
    this.bufferSize = 512,
    this.tcpCongestion = 'bbr',
    this.tcpFastOpen = true,
    this.dnsStrategy = 'UseIPv4',
  });

  /// Preset for maximum speed (YouTube, Streaming, Downloads)
  factory SpeedOptimization.maxSpeed() {
    return const SpeedOptimization(
      muxEnabled: true,
      muxConcurrency: 16,
      bufferSize: 2048,
      tcpCongestion: 'bbr',
      tcpFastOpen: true,
      dnsStrategy: 'UseIPv4',
    );
  }

  /// Preset for balanced performance
  factory SpeedOptimization.balanced() {
    return const SpeedOptimization(
      muxEnabled: true,
      muxConcurrency: 8,
      bufferSize: 512,
      tcpCongestion: 'bbr',
      tcpFastOpen: true,
      dnsStrategy: 'UseIPv4',
    );
  }

  /// Preset for battery saving
  factory SpeedOptimization.batterySaver() {
    return const SpeedOptimization(
      muxEnabled: false,
      muxConcurrency: 4,
      bufferSize: 128,
      tcpCongestion: 'cubic',
      tcpFastOpen: false,
      dnsStrategy: 'UseIPv4',
    );
  }

  /// Convert to V2Ray JSON config
  Map<String, dynamic> toV2RayConfig() {
    return {
      'mux': {
        'enabled': muxEnabled,
        'concurrency': muxConcurrency,
      },
      'policy': {
        'levels': {
          '0': {
            'uplinkOnly': 0,
            'downlinkOnly': 0,
            'bufferSize': bufferSize,
          }
        },
        'system': {
          'statsInboundUplink': true,
          'statsInboundDownlink': true,
          'statsOutboundUplink': true,
          'statsOutboundDownlink': true,
        }
      },
      'streamSettings': {
        'sockopt': {
          'tcpFastOpen': tcpFastOpen,
          'tcpCongestion': tcpCongestion,
          'tcpKeepAliveInterval': 30,
          'mark': 255,
        }
      },
      'dns': {
        'servers': [
          'https://1.1.1.1/dns-query',
          'https://8.8.8.8/dns-query',
          '1.1.1.1',
          '8.8.8.8',
          'localhost'
        ],
        'queryStrategy': dnsStrategy,
        'disableCache': false,
      }
    };
  }

  /// Copy with modifications
  SpeedOptimization copyWith({
    bool? muxEnabled,
    int? muxConcurrency,
    int? bufferSize,
    String? tcpCongestion,
    bool? tcpFastOpen,
    String? dnsStrategy,
  }) {
    return SpeedOptimization(
      muxEnabled: muxEnabled ?? this.muxEnabled,
      muxConcurrency: muxConcurrency ?? this.muxConcurrency,
      bufferSize: bufferSize ?? this.bufferSize,
      tcpCongestion: tcpCongestion ?? this.tcpCongestion,
      tcpFastOpen: tcpFastOpen ?? this.tcpFastOpen,
      dnsStrategy: dnsStrategy ?? this.dnsStrategy,
    );
  }

  @override
  String toString() {
    return 'SpeedOptimization(mux: $muxEnabled, concurrency: $muxConcurrency, '
        'buffer: ${bufferSize}KB, congestion: $tcpCongestion)';
  }
}

/// Speed optimization mode presets
enum SpeedMode {
  maxSpeed,   // Maximum speed for streaming/downloads
  balanced,   // Balanced performance
  battery,    // Battery saver mode
  custom,     // Custom settings
}
