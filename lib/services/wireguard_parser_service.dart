import 'package:fluxvpn/models/wireguard_config.dart';
import 'package:fluxvpn/models/wireguard_interface.dart';
import 'package:fluxvpn/models/wireguard_peer.dart';

class WireGuardParserService {
  static WireGuardConfig parseConfig(String content, {String name = 'WireGuard Config'}) {
    print('🔍 Parsing WireGuard config: $name');
    
    WireGuardInterface? interface;
    final List<WireGuardPeer> peers = [];
    
    String? currentSection;
    Map<String, String> interfaceData = {};
    Map<String, String> peerData = {};
    
    final lines = content.split('\n');
    print('📋 Total raw lines: ${lines.length}');
    
    for (var rawLine in lines) {
      final line = rawLine.trim();
      
      // Skip empty lines and comments
      if (line.isEmpty || line.startsWith('#')) continue;
      
      print('  📝 Processing: $line');
      
      // Check for section headers
      if (line.startsWith('[') && line.endsWith(']')) {
        // Save previous peer if exists
        if (currentSection == 'Peer' && peerData.isNotEmpty) {
          peers.add(_parsePeer(peerData));
          peerData = {};
        }

        final rawSection = line.substring(1, line.length - 1).trim();
        final normalizedSection = rawSection.toLowerCase();

        if (normalizedSection == 'interface') {
          currentSection = 'Interface';
          print('📌 Found [Interface] section');
        } else if (normalizedSection.startsWith('peer')) {
          currentSection = 'Peer';
          print('📌 Found [Peer] section');
        } else {
          currentSection = null;
          print('⚠️ Unknown section: [$rawSection]');
        }
        continue;
      }
      
      // Parse key-value pairs
      final equalIndex = line.indexOf('=');
      if (equalIndex > 0) {
        final key = line.substring(0, equalIndex).trim();
        final value = line.substring(equalIndex + 1).trim();
        
        print('  🔑 $key = $value (section: $currentSection)');
        
        if (currentSection == 'Interface') {
          interfaceData[key] = value;
        } else if (currentSection == 'Peer') {
          peerData[key] = value;
        }
      } else {
        print('  ⚠️ Line has no "=" sign: $line');
      }
    }
    
    // Save last peer if exists
    if (peerData.isNotEmpty) {
      peers.add(_parsePeer(peerData));
    }
    
    // Parse interface
    print('🔧 Interface data: $interfaceData');
    print('🔧 Peers count: ${peers.length}');
    
    if (interfaceData.isEmpty) {
      throw Exception('Invalid WireGuard config: Interface section not found');
    }
    
    interface = _parseInterface(interfaceData);
    
    if (peers.isEmpty) {
      throw Exception('Invalid WireGuard config: No peers found');
    }
    
    print('✅ Config parsed successfully');
    
    return WireGuardConfig(
      name: name,
      interface: interface,
      peers: peers,
    );
  }

  static WireGuardInterface _parseInterface(Map<String, String> data) {
    final privateKey = data['PrivateKey'];
    if (privateKey == null || privateKey.isEmpty) {
      throw Exception('PrivateKey is required in Interface section');
    }
    
    final addressStr = data['Address'];
    if (addressStr == null || addressStr.isEmpty) {
      throw Exception('Address is required in Interface section');
    }
    
    final addresses = addressStr.split(',').map((e) => e.trim()).toList();
    final dns = data['DNS']?.split(',').map((e) => e.trim()).toList() ?? [];
    final mtu = data['MTU'] != null ? int.tryParse(data['MTU']!) : 1420;
    final listenPort = data['ListenPort'] != null ? int.tryParse(data['ListenPort']!) : null;
    
    return WireGuardInterface(
      privateKey: privateKey,
      addresses: addresses,
      dns: dns,
      mtu: mtu,
      listenPort: listenPort,
    );
  }

  static WireGuardPeer _parsePeer(Map<String, String> data) {
    final publicKey = data['PublicKey'];
    if (publicKey == null || publicKey.isEmpty) {
      throw Exception('PublicKey is required in Peer section');
    }
    
    final endpoint = data['Endpoint'];
    if (endpoint == null || endpoint.isEmpty) {
      throw Exception('Endpoint is required in Peer section');
    }
    
    final allowedIPsStr = data['AllowedIPs'];
    if (allowedIPsStr == null || allowedIPsStr.isEmpty) {
      throw Exception('AllowedIPs is required in Peer section');
    }
    
    final allowedIPs = allowedIPsStr.split(',').map((e) => e.trim()).toList();
    final preSharedKey = data['PresharedKey'];
    final persistentKeepalive = data['PersistentKeepalive'] != null 
        ? int.tryParse(data['PersistentKeepalive']!) ?? 0
        : 0;
    
    return WireGuardPeer(
      publicKey: publicKey,
      preSharedKey: preSharedKey,
      endpoint: endpoint,
      allowedIPs: allowedIPs,
      persistentKeepalive: persistentKeepalive,
    );
  }

  static bool validateConfig(String content) {
    try {
      parseConfig(content);
      return true;
    } catch (e) {
      print('⚠️ WireGuard validation error: $e');
      return false;
    }
  }

  static String? validatePrivateKey(String key) {
    if (key.isEmpty) return 'Private key cannot be empty';
    if (key.length != 44) return 'Private key must be 44 characters (Base64)';
    
    // Basic Base64 validation
    final base64Regex = RegExp(r'^[A-Za-z0-9+/]{43}=$');
    if (!base64Regex.hasMatch(key)) {
      return 'Invalid private key format';
    }
    
    return null;
  }

  static String? validatePublicKey(String key) {
    if (key.isEmpty) return 'Public key cannot be empty';
    if (key.length != 44) return 'Public key must be 44 characters (Base64)';
    
    // Basic Base64 validation
    final base64Regex = RegExp(r'^[A-Za-z0-9+/]{43}=$');
    if (!base64Regex.hasMatch(key)) {
      return 'Invalid public key format';
    }
    
    return null;
  }

  static String? validateEndpoint(String endpoint) {
    if (endpoint.isEmpty) return 'Endpoint cannot be empty';
    
    final parts = endpoint.split(':');
    if (parts.length != 2) return 'Endpoint must be in format host:port';
    
    final port = int.tryParse(parts[1]);
    if (port == null || port < 1 || port > 65535) {
      return 'Invalid port number';
    }
    
    return null;
  }

  static String? validateCIDR(String cidr) {
    if (cidr.isEmpty) return 'CIDR cannot be empty';
    
    final parts = cidr.split('/');
    if (parts.length != 2) return 'Invalid CIDR format (must be x.x.x.x/xx)';
    
    final prefix = int.tryParse(parts[1]);
    if (prefix == null || prefix < 0 || prefix > 128) {
      return 'Invalid CIDR prefix';
    }
    
    return null;
  }
}
