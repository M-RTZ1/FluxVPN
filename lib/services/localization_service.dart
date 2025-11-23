import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluxvpn/services/error_service.dart';

/// Service for managing app localization
class LocalizationService extends ChangeNotifier {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  
  LocalizationService._internal();

  Locale _currentLocale = const Locale('en');
  
  Locale get currentLocale => _currentLocale;
  
  /// Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('fa'), // Persian/Farsi
  ];

  /// Initialize and load saved locale
  Future<void> initialize() async {
    await _loadLocale();
  }

  /// Load locale from storage
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code') ?? 'en';
      
      _currentLocale = Locale(languageCode);
      notifyListeners();
    } catch (e) {
      ErrorService().error('Failed to load locale: $e');
    }
  }

  /// Save locale to storage
  Future<void> _saveLocale(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', languageCode);
    } catch (e) {
      ErrorService().error('Failed to save locale: $e');
    }
  }

  /// Change app locale
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) {
      ErrorService().debug('Locale $locale is not supported');
      return;
    }
    
    _currentLocale = locale;
    await _saveLocale(locale.languageCode);
    notifyListeners();
    ErrorService().debug('Locale changed to: ${locale.languageCode}');
  }

  /// Get locale name for UI
  String getLocaleName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'fa':
        return 'فارسی';
      default:
        return locale.languageCode;
    }
  }

  /// Get locale flag emoji
  String getLocaleFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return '🇬🇧';
      case 'fa':
        return '🇮🇷';
      default:
        return '🌐';
    }
  }

  /// Check if current locale is RTL
  bool get isRTL => _currentLocale.languageCode == 'fa';
  
  /// Get text direction
  TextDirection get textDirection => isRTL ? TextDirection.rtl : TextDirection.ltr;
}
