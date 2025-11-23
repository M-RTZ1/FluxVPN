import 'package:fluxvpn/models/wireguard_interface.dart';
import 'package:fluxvpn/models/wireguard_peer.dart';
import 'package:uuid/uuid.dart';

class WireGuardConfig {
  final String id;
  final String name;
  final WireGuardInterface interface;
  final List<WireGuardPeer> peers;
  final DateTime createdAt;
  final DateTime lastModified;

  WireGuardConfig({
    String? id,
    required this.name,
    required this.interface,
    required this.peers,
    DateTime? createdAt,
    DateTime? lastModified,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        lastModified = lastModified ?? DateTime.now();

  factory WireGuardConfig.fromJson(Map<String, dynamic> json) {
    return WireGuardConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      interface: WireGuardInterface.fromJson(json['interface'] as Map<String, dynamic>),
      peers: (json['peers'] as List<dynamic>)
          .map((e) => WireGuardPeer.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastModified: DateTime.parse(json['lastModified'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'interface': interface.toJson(),
      'peers': peers.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
    };
  }

  WireGuardConfig copyWith({
    String? name,
    WireGuardInterface? interface,
    List<WireGuardPeer>? peers,
  }) {
    return WireGuardConfig(
      id: id,
      name: name ?? this.name,
      interface: interface ?? this.interface,
      peers: peers ?? this.peers,
      createdAt: createdAt,
      lastModified: DateTime.now(),
    );
  }

  // Convert to wg-quick format
  String toWgQuick() {
    final buffer = StringBuffer();
    
    // Interface section
    buffer.writeln('[Interface]');
    buffer.writeln('PrivateKey = ${interface.privateKey}');
    buffer.writeln('Address = ${interface.addresses.join(', ')}');
    if (interface.dns.isNotEmpty) {
      buffer.writeln('DNS = ${interface.dns.join(', ')}');
    }
    if (interface.mtu != null) {
      buffer.writeln('MTU = ${interface.mtu}');
    }
    if (interface.listenPort != null) {
      buffer.writeln('ListenPort = ${interface.listenPort}');
    }
    
    // Peers section
    for (var peer in peers) {
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
}
