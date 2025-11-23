import 'package:fluent_ui/fluent_ui.dart';
// import 'package:flutter_localizations/flutter_localizations.dart'; // Removed unused import
import 'package:provider/provider.dart';
import 'package:fluxvpn/l10n/app_localizations.dart';
import 'package:fluxvpn/services/v2ray_service.dart';
import 'package:fluxvpn/services/theme_service.dart';
import 'package:fluxvpn/services/error_service.dart';
import 'package:fluxvpn/services/statistics_service.dart';
import 'package:fluxvpn/services/wireguard_service.dart';
import 'package:fluxvpn/services/localization_service.dart';
import 'package:fluxvpn/providers/language_provider.dart';
import 'package:fluxvpn/services/wallpaper_service.dart';
import 'package:fluxvpn/services/update_service.dart';
import 'package:fluxvpn/theme/app_theme.dart';
import 'package:fluxvpn/screens/home_screen.dart';
import 'package:fluxvpn/screens/servers_screen.dart';
import 'package:fluxvpn/screens/subscriptions_screen.dart';
import 'package:fluxvpn/screens/settings_screen.dart';
import 'package:fluxvpn/utils/translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ErrorService
  final errorService = ErrorService();
  await errorService.initialize();

  // Clear old logs (keep last 7 days)
  await errorService.clearOldLogs();

  // Initialize LocalizationService
  final localizationService = LocalizationService();
  await localizationService.initialize();

  errorService.info('Application started');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => V2RayService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => StatisticsService()),
        ChangeNotifierProvider(create: (_) => WireGuardService()),
        ChangeNotifierProvider(create: (_) => LocalizationService()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => WallpaperService()),
        ChangeNotifierProvider(create: (_) => UpdateService()),
      ],
      child: Consumer2<ThemeService, LocalizationService>(
        builder: (context, themeService, localizationService, child) {
          // استفاده از فونت فارسی برای زبان فارسی
          final fontFamily = localizationService.isRTL ? 'Vazirmatn' : null;

          return FluentApp(
            title: 'FluxVPN',
            themeMode: themeService.themeMode,
            darkTheme: AppTheme.darkTheme(fontFamily: fontFamily),
            theme: AppTheme.lightTheme(fontFamily: fontFamily),
            home: const MainNavigation(),
            debugShowCheckedModeBanner: false,
            locale: localizationService.currentLocale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            builder: (context, child) {
              return Directionality(
                textDirection: localizationService.textDirection,
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final service = Provider.of<V2RayService>(context, listen: false);
    await service.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;

    final screens = [
      const HomeScreen(),
      const ServersScreen(),
      const SubscriptionsScreen(),
      const SettingsScreen(),
    ];

    return Column(
      children: [
        // Custom AppBar - Enhanced UI
        Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
            gradient: isDark
                ? LinearGradient(
                    colors: [const Color(0xFF0F0F0F), const Color(0xFF1A1A1A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [Colors.white, const Color(0xFFFAFAFA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Enhanced Icon Container - Modern Design
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryGradientStart,
                      AppTheme.primaryGradientEnd,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGradientStart.withValues(
                        alpha: 0.5,
                      ),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: AppTheme.primaryGradientStart.withValues(
                        alpha: 0.2,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(FluentIcons.globe, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 16),
              // App Name with Better Typography
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FluxVPN',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: isDark ? Colors.white : Colors.black,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Body
        Expanded(child: screens[_selectedIndex]),
        // Bottom Navigation Bar
        Container(
          height: 65,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: Consumer<LocalizationService>(
            builder: (context, localizationService, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    0,
                    FluentIcons.home,
                    Translations.tr(context, 'Home'),
                    isDark,
                  ),
                  _buildNavItem(
                    1,
                    FluentIcons.server,
                    Translations.tr(context, 'Servers'),
                    isDark,
                  ),
                  _buildNavItem(
                    2,
                    FluentIcons.cloud,
                    Translations.tr(context, 'Subscriptions'),
                    isDark,
                  ),
                  _buildNavItem(
                    3,
                    FluentIcons.settings,
                    Translations.tr(context, 'Settings'),
                    isDark,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected
                    ? AppTheme.md3Primary
                    : (isDark ? Colors.grey : const Color(0xFF757575)),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? AppTheme.md3Primary
                      : (isDark ? Colors.grey : const Color(0xFF757575)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
