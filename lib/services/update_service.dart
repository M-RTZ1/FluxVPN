import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class ReleaseInfo {
  final String version;
  final String name;
  final String body;
  final String url;
  final DateTime publishedAt;

  const ReleaseInfo({
    required this.version,
    required this.name,
    required this.body,
    required this.url,
    required this.publishedAt,
  });
}

class UpdateService extends ChangeNotifier {
  static const String _repoOwner = 'M-RTZ1';
  static const String _repoName = 'FluxVPN';

  ReleaseInfo? _latestRelease;
  String? _currentVersion;
  DateTime? _lastChecked;
  String? _error;
  bool _isChecking = false;

  ReleaseInfo? get latestRelease => _latestRelease;
  String? get currentVersion => _currentVersion;
  DateTime? get lastChecked => _lastChecked;
  String? get error => _error;
  bool get isChecking => _isChecking;
  bool get hasUpdate =>
      _latestRelease != null &&
      _currentVersion != null &&
      _isVersionNewer(_latestRelease!.version, _currentVersion!);

  Future<void> _ensureCurrentVersion() async {
    if (_currentVersion != null) return;
    final info = await PackageInfo.fromPlatform();
    _currentVersion = info.version;
  }

  Future<void> checkForUpdates() async {
    if (_isChecking) return;
    _isChecking = true;
    _error = null;
    notifyListeners();

    try {
      await _ensureCurrentVersion();

      final uri = Uri.parse(
        'https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest',
      );
      final response = await http.get(
        uri,
        headers: const {
          'Accept': 'application/vnd.github+json',
          'X-GitHub-Api-Version': '2022-11-28',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('GitHub API error (${response.statusCode})');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final tagName = (data['tag_name'] ?? '').toString();
      final version = tagName.replaceFirst(RegExp('^v'), '').trim();

      _latestRelease = ReleaseInfo(
        version: version.isEmpty
            ? (data['name'] ?? 'Unknown').toString()
            : version,
        name: (data['name'] ?? 'Latest Release').toString(),
        body: (data['body'] ?? '').toString(),
        url: (data['html_url'] ?? '').toString(),
        publishedAt:
            DateTime.tryParse(data['published_at'] ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _lastChecked = DateTime.now();
      _isChecking = false;
      notifyListeners();
    }
  }

  bool _isVersionNewer(String latest, String current) {
    final latestParts = _toVersionParts(latest);
    final currentParts = _toVersionParts(current);

    for (var i = 0; i < 3; i++) {
      final latestPart = latestParts[i];
      final currentPart = currentParts[i];
      if (latestPart > currentPart) return true;
      if (latestPart < currentPart) return false;
    }
    return false;
  }

  List<int> _toVersionParts(String version) {
    final cleaned = version.replaceAll(RegExp(r'[^0-9.]'), '');
    final parts = cleaned.split('.');
    return List<int>.generate(3, (index) {
      if (index < parts.length) {
        return int.tryParse(parts[index]) ?? 0;
      }
      return 0;
    });
  }
}
