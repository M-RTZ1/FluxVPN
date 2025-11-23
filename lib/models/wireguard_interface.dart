class WireGuardInterface {
  final String privateKey;
  final List<String> addresses;
  final List<String> dns;
  final int? mtu;
  final int? listenPort;

  WireGuardInterface({
    required this.privateKey,
    required this.addresses,
    this.dns = const [],
    this.mtu = 1420,
    this.listenPort,
  });

  factory WireGuardInterface.fromJson(Map<String, dynamic> json) {
    return WireGuardInterface(
      privateKey: json['privateKey'] as String,
      addresses: (json['addresses'] as List<dynamic>).map((e) => e.toString()).toList(),
      dns: json['dns'] != null 
          ? (json['dns'] as List<dynamic>).map((e) => e.toString()).toList()
          : [],
      mtu: json['mtu'] as int? ?? 1420,
      listenPort: json['listenPort'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'privateKey': privateKey,
      'addresses': addresses,
      'dns': dns,
      'mtu': mtu,
      'listenPort': listenPort,
    };
  }

  WireGuardInterface copyWith({
    String? privateKey,
    List<String>? addresses,
    List<String>? dns,
    int? mtu,
    int? listenPort,
  }) {
    return WireGuardInterface(
      privateKey: privateKey ?? this.privateKey,
      addresses: addresses ?? this.addresses,
      dns: dns ?? this.dns,
      mtu: mtu ?? this.mtu,
      listenPort: listenPort ?? this.listenPort,
    );
  }
}
