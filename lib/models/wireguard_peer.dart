class WireGuardPeer {
  final String publicKey;
  final String? preSharedKey;
  final String endpoint;
  final List<String> allowedIPs;
  final int persistentKeepalive;

  WireGuardPeer({
    required this.publicKey,
    this.preSharedKey,
    required this.endpoint,
    required this.allowedIPs,
    this.persistentKeepalive = 0,
  });

  factory WireGuardPeer.fromJson(Map<String, dynamic> json) {
    return WireGuardPeer(
      publicKey: json['publicKey'] as String,
      preSharedKey: json['preSharedKey'] as String?,
      endpoint: json['endpoint'] as String,
      allowedIPs: (json['allowedIPs'] as List<dynamic>).map((e) => e.toString()).toList(),
      persistentKeepalive: json['persistentKeepalive'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'publicKey': publicKey,
      'preSharedKey': preSharedKey,
      'endpoint': endpoint,
      'allowedIPs': allowedIPs,
      'persistentKeepalive': persistentKeepalive,
    };
  }

  WireGuardPeer copyWith({
    String? publicKey,
    String? preSharedKey,
    String? endpoint,
    List<String>? allowedIPs,
    int? persistentKeepalive,
  }) {
    return WireGuardPeer(
      publicKey: publicKey ?? this.publicKey,
      preSharedKey: preSharedKey ?? this.preSharedKey,
      endpoint: endpoint ?? this.endpoint,
      allowedIPs: allowedIPs ?? this.allowedIPs,
      persistentKeepalive: persistentKeepalive ?? this.persistentKeepalive,
    );
  }
}
