import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluxvpn/models/speed_optimization.dart';
import 'package:fluxvpn/services/error_service.dart';

/// Service for managing speed optimization settings
class SpeedOptimizationService extends ChangeNotifier {
  static final SpeedOptimizationService _instance = SpeedOptimizationService._internal();
  factory SpeedOptimizationService() => _instance;
  
  SpeedOptimizationService._internal();

  SpeedOptimization _currentSettings = SpeedOptimization.balanced();
  SpeedMode _currentMode = SpeedMode.balanced;

  SpeedOptimization get currentSettings => _currentSettings;
  SpeedMode get currentMode => _currentMode;

  /// Initialize and load saved settings
  Future<void> initialize() async {
    await _loadSettings();
  }

  /// Load settings from storage
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final modeIndex = prefs.getInt('speed_mode') ?? SpeedMode.balanced.index;
      _currentMode = SpeedMode.values[modeIndex];
      
      // Load custom settings if mode is custom
      if (_currentMode == SpeedMode.custom) {
        _currentSettings = SpeedOptimization(
          muxEnabled: prefs.getBool('mux_enabled') ?? true,
          muxConcurrency: prefs.getInt('mux_concurrency') ?? 8,
          bufferSize: prefs.getInt('buffer_size') ?? 512,
          tcpCongestion: prefs.getString('tcp_congestion') ?? 'bbr',
          tcpFastOpen: prefs.getBool('tcp_fast_open') ?? true,
          dnsStrategy: prefs.getString('dns_strategy') ?? 'UseIPv4',
        );
      } else {
        _currentSettings = _getPresetSettings(_currentMode);
      }
      
      notifyListeners();
    } catch (e) {
      ErrorService().error('Failed to load speed optimization settings: $e');
    }
  }

  /// Save current settings
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setInt('speed_mode', _currentMode.index);
      
      if (_currentMode == SpeedMode.custom) {
        await prefs.setBool('mux_enabled', _currentSettings.muxEnabled);
        await prefs.setInt('mux_concurrency', _currentSettings.muxConcurrency);
        await prefs.setInt('buffer_size', _currentSettings.bufferSize);
        await prefs.setString('tcp_congestion', _currentSettings.tcpCongestion);
        await prefs.setBool('tcp_fast_open', _currentSettings.tcpFastOpen);
        await prefs.setString('dns_strategy', _currentSettings.dnsStrategy);
      }
    } catch (e) {
      ErrorService().error('Failed to save speed optimization settings: $e');
    }
  }

  /// Set speed mode preset
  Future<void> setSpeedMode(SpeedMode mode) async {
    _currentMode = mode;
    _currentSettings = _getPresetSettings(mode);
    await _saveSettings();
    notifyListeners();
    
    ErrorService().debug('Speed mode changed to: $mode');
    ErrorService().debug('Settings: $_currentSettings');
  }

  /// Set custom settings
  Future<void> setCustomSettings(SpeedOptimization settings) async {
    _currentMode = SpeedMode.custom;
    _currentSettings = settings;
    await _saveSettings();
    notifyListeners();
    
    ErrorService().debug('Custom speed settings applied: $settings');
  }

  /// Get preset settings for a mode
  SpeedOptimization _getPresetSettings(SpeedMode mode) {
    switch (mode) {
      case SpeedMode.maxSpeed:
        return SpeedOptimization.maxSpeed();
      case SpeedMode.balanced:
        return SpeedOptimization.balanced();
      case SpeedMode.battery:
        return SpeedOptimization.batterySaver();
      case SpeedMode.custom:
        return _currentSettings;
    }
  }

  /// Get mode name for UI
  String getModeName(SpeedMode mode) {
    switch (mode) {
      case SpeedMode.maxSpeed:
        return '🚀 حداکثر سرعت';
      case SpeedMode.balanced:
        return '⚖️ متعادل';
      case SpeedMode.battery:
        return '🔋 ذخیره باتری';
      case SpeedMode.custom:
        return '⚙️ سفارشی';
    }
  }

  /// Get mode description for UI
  String getModeDescription(SpeedMode mode) {
    switch (mode) {
      case SpeedMode.maxSpeed:
        return 'بهینه برای YouTube، Netflix و دانلود';
      case SpeedMode.balanced:
        return 'تعادل بین سرعت و مصرف باتری';
      case SpeedMode.battery:
        return 'کاهش مصرف باتری';
      case SpeedMode.custom:
        return 'تنظیمات دستی';
    }
  }

  /// Get expected speed improvement
  String getSpeedImprovement(SpeedMode mode) {
    switch (mode) {
      case SpeedMode.maxSpeed:
        return '+150% سرعت';
      case SpeedMode.balanced:
        return '+80% سرعت';
      case SpeedMode.battery:
        return '+30% سرعت';
      case SpeedMode.custom:
        return 'متغیر';
    }
  }
}
