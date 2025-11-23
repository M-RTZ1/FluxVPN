import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Scaffold;
import 'package:provider/provider.dart';
import 'package:fluxvpn/services/v2ray_service.dart';
import 'package:fluxvpn/services/wireguard_service.dart';
import 'package:fluxvpn/services/country_detector.dart';
import 'package:fluxvpn/services/theme_service.dart';
import 'package:fluxvpn/services/statistics_service.dart';
import 'package:fluxvpn/services/wallpaper_service.dart';
import 'package:fluxvpn/theme/app_theme.dart';
import 'package:fluxvpn/widgets/animated_connect_button.dart';
import 'package:fluxvpn/widgets/animated_background.dart';
import 'package:fluxvpn/widgets/stats_card.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isConnecting = false;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  Timer? _statisticsTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _startStatisticsTimer();
  }

  void _startStatisticsTimer() {
    // Cancel existing timer if any
    _statisticsTimer?.cancel();

    _statisticsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final v2rayService = Provider.of<V2RayService>(context, listen: false);

      // Stop timer if not connected
      if (!v2rayService.isConnected) {
        timer.cancel();
        return;
      }

      final status = v2rayService.currentStatus;
      if (status != null) {
        final statsService = Provider.of<StatisticsService>(
          context,
          listen: false,
        );
        statsService.addDataPoint(status);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _statisticsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<V2RayService, ThemeService>(
      builder: (context, v2rayService, themeService, child) {
        final isConnected = v2rayService.isConnected;
        final isDark = themeService.isDarkMode;
        final activeConfig = v2rayService.activeConfig;
        final status = v2rayService.currentStatus;
        final wallpaperService = Provider.of<WallpaperService>(context);
        final wallpaperPath = wallpaperService.currentWallpaper?.path;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: AnimatedBackground(
            isConnected: isConnected,
            wallpaperPath: wallpaperPath,
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // 🎯 3D GLOWING SPHERE CONNECT BUTTON with advanced animations
                    // ✅ RepaintBoundary جلوی repaint غیرضروری رو می‌گیره
                    RepaintBoundary(
                      child: AnimatedConnectButton(
                        isConnected: isConnected,
                        isConnecting: _isConnecting,
                        onTap: () => _handleConnectionToggle(v2rayService),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // 📊 STATUS TEXT with animation and indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isConnected
                                ? AppTheme.md3Success
                                : Colors.grey,
                            boxShadow: isConnected
                                ? [
                                    BoxShadow(
                                      color: AppTheme.md3Success.withValues(
                                        alpha: 0.5,
                                      ),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: isConnected
                                ? AppTheme.md3Success
                                : AppTheme.md3OnSurfaceVariant,
                            letterSpacing: 1,
                          ),
                          child: Text(
                            isConnected ? 'CONNECTED' : 'DISCONNECTED',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Subtitle
                    Text(
                      isConnected
                          ? 'Your connection is protected'
                          : 'Tap or swipe down to connect',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // 📊 STATS CARD - Download/Upload
                    if (isConnected && status != null)
                      StatsCard(
                        downloadSpeed: AppTheme.formatSpeed(
                          status.downloadSpeed,
                        ),
                        uploadSpeed: AppTheme.formatSpeed(status.uploadSpeed),
                        totalDownload: AppTheme.formatBytes(status.download),
                        totalUpload: AppTheme.formatBytes(status.upload),
                        isConnected: isConnected,
                      ),
                    const SizedBox(height: 36),
                    if (activeConfig != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.md3DarkSurfaceVariant
                              : AppTheme.md3LightSurfaceVariant,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isConnected
                                ? AppTheme.md3Success.withValues(alpha: 0.3)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              CountryDetector.getFlagEmoji(
                                activeConfig.countryCode ?? 'XX',
                              ),
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activeConfig.remark,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.md3OnSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${activeConfig.address}:${activeConfig.port}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.md3OnSurfaceVariant
                                          .withValues(alpha: 0.6),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    // WireGuard section
                    const SizedBox(height: 16),
                    Consumer<WireGuardService>(
                      builder: (context, wgService, child) {
                        final selectedConfig = wgService.selectedConfig;
                        final isWgConnected = wgService.isConnected;

                        if (selectedConfig == null)
                          return const SizedBox.shrink();

                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.md3Primary.withValues(alpha: 0.12),
                                    AppTheme.md3Primary.withValues(alpha: 0.04),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isWgConnected
                                      ? AppTheme.md3Success.withValues(
                                          alpha: 0.5,
                                        )
                                      : AppTheme.md3Primary.withValues(
                                          alpha: 0.3,
                                        ),
                                  width: isWgConnected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        FluentIcons.network_tower,
                                        size: 16,
                                        color: AppTheme.md3Primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          selectedConfig.name,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isWgConnected)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.md3Success
                                                .withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            'ACTIVE',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.md3Success,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (!isWgConnected) ...[
                                    const SizedBox(height: 8),
                                    Expander(
                                      header: Row(
                                        children: [
                                          Icon(
                                            FluentIcons.info,
                                            size: 14,
                                            color: Colors.orange,
                                          ),
                                          const SizedBox(width: 6),
                                          const Text(
                                            'VPN Permission Required',
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                      content: const Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          '1. Tap Connect button\n'
                                          '2. Allow VPN permission when prompted\n\n'
                                          'If no dialog appears:\n'
                                          'Settings → Apps → FluxVPN → Permissions',
                                          style: TextStyle(
                                            fontSize: 11,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  FilledButton(
                                    onPressed: wgService.isConnecting
                                        ? null
                                        : () async {
                                            if (isWgConnected) {
                                              try {
                                                await wgService.disconnect();
                                              } catch (e) {
                                                // Ignore disconnect errors
                                              }
                                            } else {
                                              try {
                                                final success = await wgService
                                                    .connect(selectedConfig);
                                                if (!success &&
                                                    context.mounted) {
                                                  await showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        ContentDialog(
                                                          title: const Text(
                                                            'Connection Failed',
                                                          ),
                                                          content: const Text(
                                                            'Could not connect to VPN. Please try again or check VPN permissions in Android settings.',
                                                          ),
                                                          actions: [
                                                            Button(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                  ),
                                                              child: const Text(
                                                                'OK',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                  );
                                                }
                                              } catch (e) {
                                                if (context.mounted) {
                                                  final errorMsg = e
                                                      .toString()
                                                      .replaceAll(
                                                        'Exception: ',
                                                        '',
                                                      );
                                                  await showDialog(
                                                    context: context,
                                                    builder: (context) => ContentDialog(
                                                      title: const Text(
                                                        'Connection Failed',
                                                      ),
                                                      content: SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(errorMsg),
                                                            if (errorMsg
                                                                .contains(
                                                                  'Settings',
                                                                ))
                                                              const Padding(
                                                                padding:
                                                                    EdgeInsets.only(
                                                                      top: 12,
                                                                    ),
                                                                child: Text(
                                                                  'Note: You need to grant VPN permission to connect.',
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: [
                                                        FilledButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                              ),
                                                          child: const Text(
                                                            'OK',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                          },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isWgConnected
                                              ? FluentIcons.plug_disconnected
                                              : FluentIcons.plug_connected,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          isWgConnected
                                              ? 'Disconnect'
                                              : 'Connect',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleConnectionToggle(V2RayService service) async {
    setState(() {
      _isConnecting = true;
    });

    try {
      if (service.isConnected) {
        await service.disconnect();
      } else {
        final selectedConfig = await service.loadSelectedConfig();
        if (selectedConfig == null) {
          final configs = await service.loadConfigs();
          if (configs.isEmpty) {
            if (mounted) {
              await displayInfoBar(
                context,
                builder: (context, close) {
                  return const InfoBar(
                    title: Text('No Servers'),
                    content: Text('Please add servers from the Servers tab'),
                    severity: InfoBarSeverity.warning,
                  );
                },
                duration: const Duration(seconds: 3),
              );
            }
          } else {
            if (mounted) {
              await displayInfoBar(
                context,
                builder: (context, close) {
                  return const InfoBar(
                    title: Text('No Server Selected'),
                    content: Text(
                      'Please select a server from the Servers tab',
                    ),
                    severity: InfoBarSeverity.info,
                  );
                },
                duration: const Duration(seconds: 3),
              );
            }
          }
        } else {
          final success = await service.connect(selectedConfig);
          if (mounted) {
            await displayInfoBar(
              context,
              builder: (context, close) {
                return InfoBar(
                  title: Text(success ? 'Connected' : 'Connection Failed'),
                  content: Text(
                    success
                        ? 'Connected to ${selectedConfig.remark}'
                        : 'Failed to connect to server',
                  ),
                  severity: success
                      ? InfoBarSeverity.success
                      : InfoBarSeverity.error,
                );
              },
              duration: const Duration(seconds: 2),
            );
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }
}
