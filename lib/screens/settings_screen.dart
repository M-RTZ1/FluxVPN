import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:fluxvpn/services/v2ray_service.dart';
import 'package:fluxvpn/services/theme_service.dart';
import 'package:fluxvpn/services/localization_service.dart';
import 'package:fluxvpn/services/error_service.dart';
import 'package:fluxvpn/models/subscription.dart';
import 'package:fluxvpn/utils/translations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluxvpn/screens/per_app_proxy_screen.dart';
import 'package:fluxvpn/screens/language_settings_screen.dart';
import 'package:fluxvpn/screens/wallpaper_settings_screen.dart';
import 'package:fluxvpn/providers/language_provider.dart';
import 'package:fluxvpn/services/wallpaper_service.dart';
import 'package:fluxvpn/services/update_service.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoConnect = false;
  bool _killSwitch = false;
  bool _hasTriggeredUpdateCheck = false;

  // Helper method for translation
  String tr(String key) => Translations.tr(context, key);

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _scheduleUpdateCheck();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoConnect = prefs.getBool('auto_connect') ?? false;
      _killSwitch = prefs.getBool('kill_switch') ?? false;
    });
  }

  void _scheduleUpdateCheck() {
    if (_hasTriggeredUpdateCheck) return;
    _hasTriggeredUpdateCheck = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final updateService = Provider.of<UpdateService>(context, listen: false);
      await updateService.checkForUpdates();
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;
    final updateService = Provider.of<UpdateService>(context);

    return ScaffoldPage(
      header: PageHeader(
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF0066FF), const Color(0xFF0099FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0066FF).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  FluentIcons.settings,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                tr('Settings'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      content: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildSection('General', [
            _buildSettingTile(
              'Auto Connect',
              'Automatically connect on app start',
              FluentIcons.play_solid,
              _autoConnect,
              (value) {
                setState(() {
                  _autoConnect = value;
                });
                _saveSetting('auto_connect', value);
              },
            ),
            _buildSettingTile(
              'Kill Switch',
              'Block internet if VPN disconnects',
              FluentIcons.shield_solid,
              _killSwitch,
              (value) {
                setState(() {
                  _killSwitch = value;
                });
                _saveSetting('kill_switch', value);
              },
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('Network', [
            _buildNavigationTile(
              'Per-App Proxy',
              'Choose which apps use VPN',
              FluentIcons.permissions,
              () {
                Navigator.push(
                  context,
                  FluentPageRoute(
                    builder: (context) => const PerAppProxyScreen(),
                  ),
                );
              },
            ),
            _buildNavigationTile(
              'DNS Settings',
              'Configure custom DNS servers',
              FluentIcons.server_enviroment,
              () => _showDnsDialog(),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('Appearance', [
            // Wallpaper Settings
            _buildNavigationTile(
              'Wallpaper Settings',
              'Customize your app wallpaper',
              FluentIcons.photo2,
              () {
                Navigator.push(
                  context,
                  FluentPageRoute(
                    builder: (context) => const WallpaperSettingsScreen(),
                  ),
                );
              },
            ),
            // Language Selection
            _buildNavigationTile(
              'Language Settings',
              'Change app language',
              FluentIcons.locale_language,
              () {
                Navigator.push(
                  context,
                  FluentPageRoute(
                    builder: (context) => const LanguageSettingsScreen(),
                  ),
                );
              },
            ),
            // Dark Mode Toggle
            Consumer<ThemeService>(
              builder: (context, themeService, child) {
                return _buildSettingTile(
                  'Dark Mode',
                  themeService.isDarkMode
                      ? 'Using dark theme'
                      : 'Using light theme',
                  themeService.isDarkMode
                      ? FluentIcons.clear_night
                      : FluentIcons.sunny,
                  themeService.isDarkMode,
                  (value) async {
                    await themeService.setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                );
              },
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('Data', [
            _buildActionTile(
              'Backup Configs',
              'Export all configs to Downloads',
              FluentIcons.cloud_upload,
              () => _backupConfigs(),
            ),
            _buildActionTile(
              'Restore Configs',
              'Import configs from backup file',
              FluentIcons.cloud_download,
              () => _restoreConfigs(),
            ),
            _buildActionTile(
              'Clear Server Cache',
              'Clear all cached server data',
              FluentIcons.clear,
              () => _clearCache(),
            ),
            _buildActionTile(
              'Clear All Data',
              'Reset all settings and servers',
              FluentIcons.delete,
              () => _clearAllData(),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('Updates', [_buildUpdateTile(updateService)]),
        ],
      ),
    );
  }

  Widget _buildUpdateTile(UpdateService updateService) {
    final hasUpdate = updateService.hasUpdate;
    final isChecking = updateService.isChecking;
    final error = updateService.error;
    final release = updateService.latestRelease;
    final currentVersion = updateService.currentVersion ?? '-';
    final latestVersion = release?.version ?? '-';

    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (error != null) {
      statusText = tr('Update failed');
      statusColor = Colors.red;
      statusIcon = FluentIcons.error_badge;
    } else if (isChecking) {
      statusText = tr('Checking for updates');
      statusColor = const Color(0xFF0099FF);
      statusIcon = FluentIcons.sync;
    } else if (hasUpdate) {
      statusText = tr('Update available');
      statusColor = const Color(0xFFFFA000);
      statusIcon = FluentIcons.new_team_project;
    } else {
      statusText = tr('You are up to date');
      statusColor = Colors.green;
      statusIcon = FluentIcons.check_mark;
    }

    final releaseNotes = release?.body.trim();
    final previewNotes = (releaseNotes != null && releaseNotes.isNotEmpty)
        ? (releaseNotes.length > 220
              ? '${releaseNotes.substring(0, 220)}…'
              : releaseNotes)
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(statusIcon, color: statusColor, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('Updates'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${tr('Current version')}: $currentVersion',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            '${tr('Latest version')}: $latestVersion',
            style: TextStyle(
              fontSize: 12,
              color: hasUpdate
                  ? statusColor
                  : Colors.white.withValues(alpha: 0.6),
            ),
          ),
          if (release?.name != null && release!.name.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              release.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
          if (previewNotes != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('Release Notes'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    previewNotes,
                    style: const TextStyle(fontSize: 11, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              Button(
                onPressed: isChecking
                    ? null
                    : () => _checkForUpdates(updateService),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isChecking)
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: ProgressRing(strokeWidth: 2),
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(FluentIcons.sync, size: 14),
                      ),
                    Text(tr('Check for Updates')),
                  ],
                ),
              ),
              if (hasUpdate)
                FilledButton(
                  onPressed: () => _openReleasePage(release?.url),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(FluentIcons.download, size: 14),
                      ),
                      Text(tr('Download Update')),
                    ],
                  ),
                ),
              HyperlinkButton(
                onPressed: () => _openReleasePage(release?.url ?? ''),
                child: Text(tr('Open GitHub Releases')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _checkForUpdates(UpdateService updateService) async {
    await updateService.checkForUpdates();

    if (!mounted) return;

    final error = updateService.error;
    final severity = error != null
        ? InfoBarSeverity.error
        : updateService.hasUpdate
        ? InfoBarSeverity.warning
        : InfoBarSeverity.success;

    final message =
        error ??
        (updateService.hasUpdate
            ? tr('New version available')
            : tr('You are up to date'));

    await displayInfoBar(
      context,
      builder: (context, close) {
        return InfoBar(title: Text(message), severity: severity);
      },
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _openReleasePage(String? url) async {
    final targetUrl = (url != null && url.isNotEmpty)
        ? url
        : 'https://github.com/M-RTZ1/FluxVPN/releases';

    final uri = Uri.parse(targetUrl);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && mounted) {
      await displayInfoBar(
        context,
        builder: (context, close) {
          return InfoBar(
            title: Text(tr('Update failed')),
            content: const Text('Unable to open release page'),
            severity: InfoBarSeverity.error,
          );
        },
        duration: const Duration(seconds: 3),
      );
    }
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Text(
              tr(title),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0066FF).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon, size: 20, color: const Color(0xFF0099FF)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(title),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tr(subtitle),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ToggleSwitch(checked: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: GestureDetector(
        onTap: onPressed,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0066FF).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(icon, size: 20, color: const Color(0xFF0099FF)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr(title),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tr(subtitle),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              FluentIcons.chevron_right,
              size: 20,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: GestureDetector(
        onTap: onPressed,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0066FF).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(icon, size: 20, color: const Color(0xFF0099FF)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr(title),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tr(subtitle),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              FluentIcons.chevron_right,
              size: 20,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _clearCache() async {
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear all cached server data including ping results.',
        ),
        actions: [
          Button(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);

              final service = Provider.of<V2RayService>(context, listen: false);
              service.clearPingCache();

              if (mounted) {
                await displayInfoBar(
                  context,
                  builder: (context, close) {
                    return const InfoBar(
                      title: Text('Cache Cleared'),
                      severity: InfoBarSeverity.success,
                    );
                  },
                  duration: const Duration(seconds: 2),
                );
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData() async {
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will delete all servers, subscriptions, and settings. This action cannot be undone.',
        ),
        actions: [
          Button(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);

              final service = Provider.of<V2RayService>(context, listen: false);
              await service.saveConfigs([]);
              await service.saveSubscriptions([]);
              service.clearPingCache();

              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              if (mounted) {
                await displayInfoBar(
                  context,
                  builder: (context, close) {
                    return const InfoBar(
                      title: Text('All Data Cleared'),
                      severity: InfoBarSeverity.warning,
                    );
                  },
                  duration: const Duration(seconds: 2),
                );
              }
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Future<void> _backupConfigs() async {
    try {
      final service = Provider.of<V2RayService>(context, listen: false);
      final configs = await service.loadConfigs();
      final subscriptions = await service.loadSubscriptions();

      if (configs.isEmpty && subscriptions.isEmpty) {
        if (mounted) {
          await displayInfoBar(
            context,
            builder: (context, close) {
              return const InfoBar(
                title: Text('No Data'),
                content: Text('No configs or subscriptions to backup'),
                severity: InfoBarSeverity.warning,
              );
            },
            duration: const Duration(seconds: 2),
          );
        }
        return;
      }

      final backupData = {
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
        'configs': configs.map((c) => c.toJson()).toList(),
        'subscriptions': subscriptions.map((s) => s.toJson()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory =
            await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory!.path}/fluxvpn_backup_$timestamp.json');
      await file.writeAsString(jsonString);

      if (mounted) {
        await displayInfoBar(
          context,
          builder: (context, close) {
            return InfoBar(
              title: const Text('Backup Created'),
              content: Text('Saved to: ${file.path}'),
              severity: InfoBarSeverity.success,
            );
          },
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      ErrorService().error('Error backing up configs: $e');
    }
  }

  Future<void> _restoreConfigs() async {
    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory =
            await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
      }

      final files = directory!
          .listSync()
          .where(
            (f) =>
                f.path.contains('fluxvpn_backup_') && f.path.endsWith('.json'),
          )
          .toList();

      if (files.isEmpty) {
        if (mounted) {
          await displayInfoBar(
            context,
            builder: (context, close) {
              return const InfoBar(
                title: Text('No Backups Found'),
                content: Text('No backup files found in Downloads folder'),
                severity: InfoBarSeverity.warning,
              );
            },
            duration: const Duration(seconds: 3),
          );
        }
        return;
      }

      files.sort((a, b) => b.path.compareTo(a.path));

      await showDialog(
        context: context,
        builder: (context) => ContentDialog(
          title: const Text('Select Backup File'),
          content: SizedBox(
            width: 400,
            height: 300,
            child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                final filename = file.path.split('/').last;
                return ListTile(
                  title: Text(filename),
                  subtitle: Text(
                    File(file.path).statSync().modified.toString(),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _performRestore(file.path);
                  },
                );
              },
            ),
          ),
          actions: [
            Button(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    } catch (e) {
      ErrorService().error('Error restoring configs: $e');
    }
  }

  Future<void> _performRestore(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      final service = Provider.of<V2RayService>(context, listen: false);
      int configsImported = 0;
      int subsImported = 0;

      if (backupData['configs'] != null) {
        final configsList = backupData['configs'] as List;
        final existingConfigs = await service.loadConfigs();

        for (var configJson in configsList) {
          try {
            final configMap = configJson as Map<String, dynamic>;
            final fullConfig = configMap['fullConfig'] as String;
            final parsedConfigs = await service.parseSubscriptionContent(
              fullConfig,
            );
            existingConfigs.addAll(parsedConfigs);
            configsImported++;
          } catch (e) {
            ErrorService().error('Error parsing config: $e');
          }
        }

        await service.saveConfigs(existingConfigs);
      }

      if (backupData['subscriptions'] != null) {
        final subsList = backupData['subscriptions'] as List;
        final existingSubs = await service.loadSubscriptions();

        for (var subJson in subsList) {
          try {
            final sub = Subscription.fromJson(subJson as Map<String, dynamic>);
            if (!existingSubs.any((s) => s.url == sub.url)) {
              existingSubs.add(sub);
              subsImported++;
            }
          } catch (e) {
            ErrorService().error('Error parsing subscription: $e');
          }
        }

        await service.saveSubscriptions(existingSubs);
      }

      if (mounted) {
        await displayInfoBar(
          context,
          builder: (context, close) {
            return InfoBar(
              title: const Text('Restore Complete'),
              content: Text(
                'Imported $configsImported config(s) and $subsImported subscription(s)',
              ),
              severity: InfoBarSeverity.success,
            );
          },
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      ErrorService().error('Error performing restore: $e');
    }
  }

  Future<void> _showLanguageDialog(
    LocalizationService localizationService,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Select Language / انتخاب زبان'),
        content: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: LocalizationService.supportedLocales.map((locale) {
              final isSelected = locale == localizationService.currentLocale;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Text(
                    localizationService.getLocaleFlag(locale),
                    style: const TextStyle(fontSize: 32),
                  ),
                  title: Text(
                    localizationService.getLocaleName(locale),
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontFamily: locale.languageCode == 'fa'
                          ? 'Vazirmatn'
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    locale.languageCode == 'en' ? 'English' : 'Persian',
                    style: TextStyle(fontSize: 11),
                  ),
                  trailing: isSelected
                      ? Icon(FluentIcons.check_mark, color: Colors.green)
                      : null,
                  tileColor: isSelected
                      ? ButtonState.all(Colors.green.withOpacity(0.1))
                      : null,
                  onPressed: () async {
                    await localizationService.setLocale(locale);
                    if (mounted) {
                      Navigator.of(context).pop();
                      await displayInfoBar(
                        context,
                        builder: (context, close) {
                          return InfoBar(
                            title: Text(
                              locale.languageCode == 'fa'
                                  ? 'زبان تغییر کرد'
                                  : 'Language Changed',
                            ),
                            content: Text(
                              locale.languageCode == 'fa'
                                  ? 'برنامه به ${localizationService.getLocaleName(locale)} تغییر کرد'
                                  : 'App language changed to ${localizationService.getLocaleName(locale)}',
                            ),
                            severity: InfoBarSeverity.success,
                          );
                        },
                        duration: const Duration(seconds: 2),
                      );
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          Button(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close / بستن'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDnsDialog() async {
    final service = Provider.of<V2RayService>(context, listen: false);
    bool useDns = service.useDns;
    List<String> dnsServers = service.dnsServers;

    final dns1Controller = TextEditingController(
      text: dnsServers.isNotEmpty ? dnsServers[0] : '1.1.1.1',
    );
    final dns2Controller = TextEditingController(
      text: dnsServers.length > 1 ? dnsServers[1] : '1.0.0.1',
    );

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => ContentDialog(
          title: const Text('DNS Settings'),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      checked: useDns,
                      onChanged: (value) {
                        setState(() {
                          useDns = value ?? true;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text('Use Custom DNS'),
                  ],
                ),
                const SizedBox(height: 16),
                if (useDns) ...[
                  const Text('Primary DNS', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  TextBox(controller: dns1Controller, placeholder: '1.1.1.1'),
                  const SizedBox(height: 12),
                  const Text('Secondary DNS', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  TextBox(controller: dns2Controller, placeholder: '1.0.0.1'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: FluentTheme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Popular DNS Providers:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Cloudflare: 1.1.1.1, 1.0.0.1',
                          style: TextStyle(fontSize: 11),
                        ),
                        Text(
                          'Google: 8.8.8.8, 8.8.4.4',
                          style: TextStyle(fontSize: 11),
                        ),
                        Text(
                          'Quad9: 9.9.9.9, 149.112.112.112',
                          style: TextStyle(fontSize: 11),
                        ),
                        Text(
                          'OpenDNS: 208.67.222.222, 208.67.220.220',
                          style: TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            Button(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final servers = <String>[];
                if (dns1Controller.text.isNotEmpty)
                  servers.add(dns1Controller.text.trim());
                if (dns2Controller.text.isNotEmpty)
                  servers.add(dns2Controller.text.trim());

                if (servers.isEmpty) {
                  servers.addAll(['1.1.1.1', '1.0.0.1']);
                }

                await service.saveDnsSettings(useDns, servers);
                if (context.mounted) {
                  Navigator.pop(context);
                  await displayInfoBar(
                    context,
                    builder: (context, close) {
                      return const InfoBar(
                        title: Text('DNS Settings Saved'),
                        content: Text('Changes will apply on next connection'),
                        severity: InfoBarSeverity.success,
                      );
                    },
                    duration: const Duration(seconds: 3),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    dns1Controller.dispose();
    dns2Controller.dispose();
  }
}
