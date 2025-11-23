import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language model
class Language {
  final String code; // e.g., 'en', 'fa', 'ar'
  final String name; // e.g., 'English', 'فارسی'
  final Locale locale;

  Language({
    required this.code,
    required this.name,
    required this.locale,
  });
}

/// Language Provider for managing app language
class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  
  // Supported languages
  static final List<Language> supportedLanguages = [
    Language(
      code: 'en',
      name: 'English',
      locale: const Locale('en', 'US'),
    ),
    Language(
      code: 'fa',
      name: 'فارسی',
      locale: const Locale('fa', 'IR'),
    ),
    Language(
      code: 'ar',
      name: 'العربية',
      locale: const Locale('ar', 'SA'),
    ),
    Language(
      code: 'es',
      name: 'Español',
      locale: const Locale('es', 'ES'),
    ),
    Language(
      code: 'fr',
      name: 'Français',
      locale: const Locale('fr', 'FR'),
    ),
    Language(
      code: 'de',
      name: 'Deutsch',
      locale: const Locale('de', 'DE'),
    ),
    Language(
      code: 'ru',
      name: 'Русский',
      locale: const Locale('ru', 'RU'),
    ),
    Language(
      code: 'zh',
      name: '中文',
      locale: const Locale('zh', 'CN'),
    ),
    Language(
      code: 'ja',
      name: '日本語',
      locale: const Locale('ja', 'JP'),
    ),
    Language(
      code: 'ko',
      name: '한국어',
      locale: const Locale('ko', 'KR'),
    ),
    Language(
      code: 'pt',
      name: 'Português',
      locale: const Locale('pt', 'PT'),
    ),
    Language(
      code: 'it',
      name: 'Italiano',
      locale: const Locale('it', 'IT'),
    ),
    Language(
      code: 'nl',
      name: 'Nederlands',
      locale: const Locale('nl', 'NL'),
    ),
    Language(
      code: 'tr',
      name: 'Türkçe',
      locale: const Locale('tr', 'TR'),
    ),
    Language(
      code: 'hi',
      name: 'हिन्दी',
      locale: const Locale('hi', 'IN'),
    ),
  ];

  late Language _currentLanguage;
  bool _isLoading = false;

  Language get currentLanguage => _currentLanguage;
  Locale get currentLocale => _currentLanguage.locale;
  bool get isLoading => _isLoading;

  LanguageProvider() {
    _initialize();
  }

  /// Initialize language provider
  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);

      if (languageCode != null) {
        _currentLanguage = supportedLanguages.firstWhere(
          (lang) => lang.code == languageCode,
          orElse: () => supportedLanguages[0], // Default to English
        );
      } else {
        // Auto-detect system language
        _currentLanguage = _detectSystemLanguage();
      }
    } catch (e) {
      debugPrint('Error initializing language provider: $e');
      _currentLanguage = supportedLanguages[0]; // Default to English
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Detect system language
  Language _detectSystemLanguage() {
    final systemLocale = WidgetsBinding.instance.window.locale;
    
    try {
      return supportedLanguages.firstWhere(
        (lang) => lang.locale.languageCode == systemLocale.languageCode,
        orElse: () => supportedLanguages[0], // Default to English
      );
    } catch (e) {
      debugPrint('Error detecting system language: $e');
      return supportedLanguages[0]; // Default to English
    }
  }

  /// Change language
  Future<void> changeLanguage(String languageCode) async {
    try {
      final language = supportedLanguages.firstWhere(
        (lang) => lang.code == languageCode,
      );

      _currentLanguage = language;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);

      notifyListeners();
    } catch (e) {
      debugPrint('Error changing language: $e');
      rethrow;
    }
  }

  /// Get language by code
  Language? getLanguageByCode(String code) {
    try {
      return supportedLanguages.firstWhere((lang) => lang.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Check if language is RTL
  bool isRTL() {
    return _currentLanguage.code == 'fa' || _currentLanguage.code == 'ar';
  }

  /// Get text direction
  TextDirection getTextDirection() {
    return isRTL() ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Reset to system language
  Future<void> resetToSystemLanguage() async {
    try {
      _currentLanguage = _detectSystemLanguage();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_languageKey);

      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting to system language: $e');
      rethrow;
    }
  }
}
