import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluxvpn/providers/language_provider.dart';
import 'package:fluxvpn/services/localization_service.dart';
import 'package:fluxvpn/theme/app_theme.dart';
import 'package:fluxvpn/l10n/app_localizations.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.md3DarkBackground,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.languageSettings ?? 'Language Settings',
        ),
        backgroundColor: AppTheme.md3DarkBackground,
        elevation: 0,
      ),
      body: Builder(
        builder: (context) {
          final languageProvider = Provider.of<LanguageProvider>(context);
          final localizationService = Provider.of<LocalizationService>(
            context,
            listen: false,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Current Language Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.md3DarkSurface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.connectedGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.currentLanguage ??
                          'Current Language',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      languageProvider.currentLanguage.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Available Languages
              Text(
                AppLocalizations.of(context)?.selectLanguage ??
                    'Select Language',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Language List
              ...LanguageProvider.supportedLanguages.map<Widget>((language) {
                final isSelected =
                    languageProvider.currentLanguage.code == language.code;

                return GestureDetector(
                  onTap: () async {
                    // Update LanguageProvider state
                    await languageProvider.changeLanguage(language.code);

                    // Update app locale via LocalizationService (controls FluentApp)
                    await localizationService.setLocale(Locale(language.code));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.connectedGreen.withValues(alpha: 0.2)
                          : AppTheme.md3DarkSurface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.connectedGreen
                            : Colors.grey.withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                language.name,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppTheme.connectedGreen
                                      : Colors.white,
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                language.code.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppTheme.connectedGreen,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 24),

              // Auto Detect Button
              ElevatedButton.icon(
                onPressed: () async {
                  await languageProvider.resetToSystemLanguage();

                  // Apply detected language to app locale as well
                  final code = languageProvider.currentLanguage.code;
                  await localizationService.setLocale(Locale(code));
                },
                icon: const Icon(Icons.auto_awesome),
                label: Text(
                  AppLocalizations.of(context)?.autoDetect ?? 'Auto Detect',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.connectedGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),

              const SizedBox(height: 16),

              // Info Text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Text(
                  AppLocalizations.of(context)?.restartAppToApply ??
                      'Restart the app to apply changes',
                  style: const TextStyle(color: Colors.blue, fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
