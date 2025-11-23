import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';

class StatisticsService extends ChangeNotifier {
  static final StatisticsService _instance = StatisticsService._internal();
  factory StatisticsService() => _instance;

  StatisticsService._internal();

  // Store last 60 data points (1 minute at 1 second intervals)
  final List<SpeedDataPoint> _uploadHistory = [];
  final List<SpeedDataPoint> _downloadHistory = [];
  final int _maxDataPoints = 60;
  
  // Debounce mechanism to reduce UI rebuilds
  Timer? _notifyTimer;
  bool _hasPendingNotify = false;

  List<SpeedDataPoint> get uploadHistory => List.unmodifiable(_uploadHistory);
  List<SpeedDataPoint> get downloadHistory => List.unmodifiable(_downloadHistory);

  void addDataPoint(V2RayStatus status) {
    final now = DateTime.now();
    
    // Add upload data
    _uploadHistory.add(SpeedDataPoint(
      timestamp: now,
      speed: status.uploadSpeed.toDouble(),
    ));
    
    // Add download data
    _downloadHistory.add(SpeedDataPoint(
      timestamp: now,
      speed: status.downloadSpeed.toDouble(),
    ));
    
    // Keep only last N data points
    if (_uploadHistory.length > _maxDataPoints) {
      _uploadHistory.removeAt(0);
    }
    if (_downloadHistory.length > _maxDataPoints) {
      _downloadHistory.removeAt(0);
    }
    
    // Debounce notifications to reduce UI rebuilds (notify every 2 seconds max)
    if (!_hasPendingNotify) {
      _hasPendingNotify = true;
      _notifyTimer = Timer(const Duration(seconds: 2), () {
        notifyListeners();
        _hasPendingNotify = false;
      });
    }
  }

  void clear() {
    _uploadHistory.clear();
    _downloadHistory.clear();
    _notifyTimer?.cancel();
    _hasPendingNotify = false;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _notifyTimer?.cancel();
    super.dispose();
  }

  double get maxSpeed {
    double maxUpload = _uploadHistory.isEmpty 
        ? 0 
        : _uploadHistory.map((e) => e.speed).reduce((a, b) => a > b ? a : b);
    double maxDownload = _downloadHistory.isEmpty 
        ? 0 
        : _downloadHistory.map((e) => e.speed).reduce((a, b) => a > b ? a : b);
    return maxUpload > maxDownload ? maxUpload : maxDownload;
  }
}

class SpeedDataPoint {
  final DateTime timestamp;
  final double speed;

  SpeedDataPoint({
    required this.timestamp,
    required this.speed,
  });
}
