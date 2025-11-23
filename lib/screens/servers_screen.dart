import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:fluxvpn/services/v2ray_service.dart';
import 'package:fluxvpn/models/v2ray_config.dart';
import 'package:fluxvpn/theme/app_theme.dart';
import 'package:fluxvpn/screens/wireguard_screen.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ServersScreen extends StatefulWidget {
  const ServersScreen({super.key});

  @override
  State<ServersScreen> createState() => _ServersScreenState();
}

class _ServersScreenState extends State<ServersScreen> {
  List<V2RayConfig> _configs = [];
  bool _isLoading = true;
  bool _isSorting = false;
  String _searchQuery = '';
  final Map<String, int?> _pingResults = {};
  String? _selectedConfigId;
  bool _showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _loadConfigs();
    _loadSelectedConfig();
  }

  Future<void> _loadSelectedConfig() async {
    final service = Provider.of<V2RayService>(context, listen: false);
    final selected = await service.loadSelectedConfig();
    if (selected != null) {
      setState(() {
        _selectedConfigId = selected.id;
      });
    }
  }

  Future<void> _loadConfigs() async {
    setState(() {
      _isLoading = true;
    });

    final service = Provider.of<V2RayService>(context, listen: false);
    final configs = await service.loadConfigs();

    setState(() {
      _configs = configs;
      _isLoading = false;
    });
  }

  Future<void> _pingAllServers() async {
    setState(() {
      _isSorting = true;
      _pingResults.clear();
    });

    final service = Provider.of<V2RayService>(context, listen: false);

    final futures = <Future>[];
    for (int i = 0; i < _configs.length; i++) {
      final config = _configs[i];

      final future = service
          .getServerDelay(config)
          .then((ping) {
            if (mounted) {
              setState(() {
                _pingResults[config.id] = ping ?? -1;
              });
            }
          })
          .catchError((e) {
            if (mounted) {
              setState(() {
                _pingResults[config.id] = -1;
              });
            }
          });

      futures.add(future);

      if (futures.length >= 10 || i == _configs.length - 1) {
        await Future.wait(futures);
        futures.clear();
      }
    }

    if (mounted) {
      setState(() {
        _sortByPing();
        _isSorting = false;
      });
    }
  }

  void _sortByPing() {
    _configs.sort((a, b) {
      final pingA = _pingResults[a.id] ?? 999999;
      final pingB = _pingResults[b.id] ?? 999999;

      if (pingA == -1 && pingB == -1) return 0;
      if (pingA == -1) return 1;
      if (pingB == -1) return -1;

      return pingA.compareTo(pingB);
    });
  }

  /// Get list of working servers (ping successful)
  List<V2RayConfig> get _workingServers {
    return _configs.where((config) {
      final ping = _pingResults[config.id];
      return ping != null && ping > 0 && ping < 999999;
    }).toList();
  }

  /// Copy all working servers to clipboard
  Future<void> _copyWorkingServers() async {
    if (_workingServers.isEmpty) {
      if (mounted) {
        await displayInfoBar(
          context,
          builder: (context, close) {
            return const InfoBar(
              title: Text('No Working Servers'),
              content: Text(
                'Please run Ping All first to find working servers',
              ),
              severity: InfoBarSeverity.warning,
            );
          },
          duration: const Duration(seconds: 2),
        );
      }
      return;
    }

    try {
      final configStrings = <String>[];

      // Sort working servers by ping (best first)
      final sortedServers = List<V2RayConfig>.from(_workingServers);
      sortedServers.sort((a, b) {
        final pingA = _pingResults[a.id] ?? 999999;
        final pingB = _pingResults[b.id] ?? 999999;
        return pingA.compareTo(pingB);
      });

      for (final config in sortedServers) {
        final ping = _pingResults[config.id];

        // Use the fullConfig which contains the complete config string
        String configStr = config.fullConfig;

        // Add header with server info
        final header =
            '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
            '📡 ${config.remark}\n'
            '⚡ Ping: ${ping}ms\n'
            '🔧 Type: ${config.configType.toUpperCase()}\n'
            '🌍 ${config.address}:${config.port}\n'
            '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

        configStrings.add('$header\n$configStr');
      }

      // Add summary header
      final summary =
          '✅ WORKING SERVERS (${sortedServers.length})\n'
          '📊 Tested: ${_configs.length} | Working: ${sortedServers.length}\n'
          '⏱️ Best Ping: ${_pingResults[sortedServers.first.id]}ms\n'
          '═══════════════════════════════════\n\n';

      final allConfigs = summary + configStrings.join('\n\n');
      await Clipboard.setData(ClipboardData(text: allConfigs));

      if (mounted) {
        await displayInfoBar(
          context,
          builder: (context, close) {
            return InfoBar(
              title: const Text('Copied Successfully'),
              content: Text(
                '${_workingServers.length} working servers copied to clipboard',
              ),
              severity: InfoBarSeverity.success,
            );
          },
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (mounted) {
        await displayInfoBar(
          context,
          builder: (context, close) {
            return InfoBar(
              title: const Text('Copy Failed'),
              content: Text(e.toString()),
              severity: InfoBarSeverity.error,
            );
          },
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  List<V2RayConfig> get _filteredConfigs {
    var filtered = _configs;

    // Apply favorites filter
    if (_showFavoritesOnly) {
      filtered = filtered.where((config) => config.isFavorite).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((config) {
        return config.remark.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            config.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            config.configType.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
      }).toList();
    }

    return filtered;
  }

  Future<void> _importWireGuardConfig() async {
    if (!mounted) return;

    await Navigator.of(
      context,
    ).push(FluentPageRoute(builder: (context) => const WireGuardScreen()));

    // Refresh to update WireGuard count in Home screen
    setState(() {});
  }

  Future<void> _importFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData == null ||
          clipboardData.text == null ||
          clipboardData.text!.isEmpty) {
        if (mounted) {
          await displayInfoBar(
            context,
            builder: (context, close) {
              return const InfoBar(
                title: Text('Empty Clipboard'),
                content: Text('Please copy a config first'),
                severity: InfoBarSeverity.warning,
              );
            },
            duration: const Duration(seconds: 2),
          );
        }
        return;
      }

      if (!mounted) return;
      final service = Provider.of<V2RayService>(context, listen: false);
      final config = await service.parseConfigFromClipboard(
        clipboardData.text!,
      );

      if (config != null) {
        await _loadConfigs();
        if (mounted) {
          await displayInfoBar(
            context,
            builder: (context, close) {
              return InfoBar(
                title: const Text('Config Added'),
                content: Text('${config.remark} added successfully'),
                severity: InfoBarSeverity.success,
              );
            },
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        await displayInfoBar(
          context,
          builder: (context, close) {
            return InfoBar(
              title: const Text('Import Failed'),
              content: Text(e.toString()),
              severity: InfoBarSeverity.error,
            );
          },
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: const Text(
          'Servers',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        commandBar: Wrap(
          spacing: 4,
          runSpacing: 4,
          alignment: WrapAlignment.end,
          children: [
            Tooltip(
              message: _showFavoritesOnly
                  ? 'Show All Servers'
                  : 'Show Favorites Only',
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: Icon(
                      _showFavoritesOnly
                          ? FluentIcons.heart_fill
                          : FluentIcons.heart,
                      size: 16,
                      color: _showFavoritesOnly ? Colors.red : null,
                    ),
                    onPressed: () {
                      setState(() {
                        _showFavoritesOnly = !_showFavoritesOnly;
                      });
                    },
                  ),
                  if (_configs.any((config) => config.isFavorite))
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${_configs.where((config) => config.isFavorite).length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Tooltip(
              message: 'Import V2Ray Config',
              child: IconButton(
                icon: const Icon(FluentIcons.paste, size: 16),
                onPressed: _importFromClipboard,
              ),
            ),
            Tooltip(
              message: 'Import WireGuard Config',
              child: IconButton(
                icon: const Icon(FluentIcons.network_tower, size: 16),
                onPressed: _importWireGuardConfig,
              ),
            ),
            Tooltip(
              message: 'Scan QR Code',
              child: IconButton(
                icon: const Icon(FluentIcons.q_r_code, size: 16),
                onPressed: _scanQRCode,
              ),
            ),
            Tooltip(
              message: 'Test All Servers',
              child: IconButton(
                icon: _isSorting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: ProgressRing(),
                      )
                    : const Icon(FluentIcons.sort, size: 16),
                onPressed: _isSorting ? null : _pingAllServers,
              ),
            ),
            if (_pingResults.values.any((ping) => ping != null && ping > 0))
              Tooltip(
                message:
                    'Copy Working Servers (${_pingResults.values.where((ping) => ping != null && ping > 0).length})',
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: Icon(
                        FluentIcons.copy,
                        size: 16,
                        color: Colors.green,
                      ),
                      onPressed: _copyWorkingServers,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '${_pingResults.values.where((ping) => ping != null && ping > 0).length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_pingResults.values.any((ping) => ping == -1))
              Tooltip(
                message: 'Delete Dead Servers',
                child: IconButton(
                  icon: Icon(FluentIcons.delete, size: 16, color: Colors.red),
                  onPressed: _deleteDeadConfigs,
                ),
              ),
            Tooltip(
              message: 'Refresh',
              child: IconButton(
                icon: const Icon(FluentIcons.refresh, size: 16),
                onPressed: _loadConfigs,
              ),
            ),
          ],
        ),
      ),
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Box
                TextBox(
                  placeholder: 'Search servers...',
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Icon(FluentIcons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Test All Servers Button
                if (_filteredConfigs.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSorting ? null : _pingAllServers,
                      child: _isSorting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: ProgressRing(strokeWidth: 2),
                                ),
                                SizedBox(width: 12),
                                Text('Testing Servers...'),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(FluentIcons.speed_high, size: 18),
                                SizedBox(width: 8),
                                Text('Test All Servers'),
                              ],
                            ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: ProgressRing())
                : _filteredConfigs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _showFavoritesOnly
                              ? FluentIcons.heart
                              : FluentIcons.server,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showFavoritesOnly
                              ? 'No Favorite Servers'
                              : 'No servers found',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _showFavoritesOnly
                              ? 'Tap the ❤️ icon on servers to add them to favorites'
                              : 'Add servers from Subscriptions',
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: _filteredConfigs.length,
                    itemBuilder: (context, index) {
                      final config = _filteredConfigs[index];
                      return _buildServerCard(config);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerCard(V2RayConfig config) {
    final ping = _pingResults[config.id];
    final service = Provider.of<V2RayService>(context, listen: false);
    final isConnected = service.activeConfig?.id == config.id;
    final isSelected = _selectedConfigId == config.id;

    final neonColor = isConnected
        ? AppTheme.neonGreen
        : isSelected
        ? AppTheme.neonCyan
        : AppTheme.getPingColor(ping);

    return GestureDetector(
      onTap: isConnected ? null : () => _handleSelectConfig(config),
      child: MouseRegion(
        cursor: isConnected
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                neonColor.withValues(alpha: 0.08),
                neonColor.withValues(alpha: 0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: neonColor.withValues(alpha: 0.2),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: neonColor.withValues(alpha: 0.1),
                blurRadius: 16,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                // Protocol Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        neonColor.withValues(alpha: 0.3),
                        neonColor.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: neonColor.withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _getProtocolIcon(config.configType),
                      color: neonColor,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Server Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        config.remark,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${config.address}:${config.port}',
                        style: TextStyle(
                          fontSize: 11,
                          color: neonColor.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 1),
                // Ping Badge
                if (ping != null && ping >= 0)
                  Container(
                    constraints: const BoxConstraints(minWidth: 38),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          neonColor.withValues(alpha: 0.2),
                          neonColor.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: neonColor.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${ping}ms',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: neonColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  )
                else if (ping != null && ping == -1)
                  Container(
                    constraints: const BoxConstraints(minWidth: 38),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.disconnectedRed.withValues(alpha: 0.25),
                          AppTheme.disconnectedRed.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.disconnectedRed.withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      'Timeout',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.disconnectedRed,
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                // Action Buttons - Compact
                SizedBox(
                  width: 24,
                  child: Tooltip(
                    message: config.isFavorite
                        ? 'Remove from Favorites'
                        : 'Add to Favorites',
                    child: IconButton(
                      icon: Icon(
                        config.isFavorite
                            ? FluentIcons.heart_fill
                            : FluentIcons.heart,
                        size: 12,
                        color: config.isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: () => _toggleFavorite(config),
                    ),
                  ),
                ),
                SizedBox(
                  width: 24,
                  child: Tooltip(
                    message: 'Test',
                    child: IconButton(
                      icon: const Icon(FluentIcons.speed_high, size: 12),
                      onPressed: () => _pingSingleServer(config),
                    ),
                  ),
                ),
                SizedBox(
                  width: 24,
                  child: Tooltip(
                    message: isConnected ? 'Disconnect' : 'Connect',
                    child: IconButton(
                      icon: Icon(
                        isConnected
                            ? FluentIcons.plug_disconnected
                            : FluentIcons.plug_connected,
                        size: 12,
                        color: isConnected
                            ? AppTheme.connectedGreen
                            : AppTheme.primaryCyan,
                      ),
                      onPressed: () => _handleConnect(config),
                    ),
                  ),
                ),
                SizedBox(
                  width: 24,
                  child: DropDownButton(
                    leading: const Icon(FluentIcons.more_vertical, size: 12),
                    items: [
                      MenuFlyoutItem(
                        leading: const Icon(FluentIcons.copy, size: 12),
                        text: const Text('Copy'),
                        onPressed: () => _copyConfig(config),
                      ),
                      MenuFlyoutItem(
                        leading: const Icon(FluentIcons.q_r_code, size: 12),
                        text: const Text('QR'),
                        onPressed: () => _showQRCode(config),
                      ),
                      if (!isConnected)
                        MenuFlyoutItem(
                          leading: Icon(
                            FluentIcons.delete,
                            size: 12,
                            color: AppTheme.disconnectedRed,
                          ),
                          text: const Text('Delete'),
                          onPressed: () => _deleteConfig(config),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSelectConfig(V2RayConfig config) async {
    setState(() {
      _selectedConfigId = config.id;
    });

    final service = Provider.of<V2RayService>(context, listen: false);
    await service.saveSelectedConfig(config);

    if (mounted) {
      await displayInfoBar(
        context,
        builder: (context, close) {
          return InfoBar(
            title: const Text('Server Selected'),
            content: Text('${config.remark} is now selected'),
            severity: InfoBarSeverity.success,
          );
        },
        duration: const Duration(seconds: 2),
      );
    }
  }

  IconData _getProtocolIcon(String type) {
    switch (type.toLowerCase()) {
      case 'vmess':
        return FluentIcons.shield;
      case 'vless':
        return FluentIcons.shield_solid;
      case 'trojan':
        return FluentIcons.security_group;
      case 'shadowsocks':
        return FluentIcons.lock_solid;
      default:
        return FluentIcons.server;
    }
  }

  Future<void> _pingSingleServer(V2RayConfig config) async {
    setState(() {
      _pingResults[config.id] = null; // Show loading
    });

    final service = Provider.of<V2RayService>(context, listen: false);
    final ping = await service.getServerDelay(config);

    if (mounted) {
      setState(() {
        _pingResults[config.id] = ping ?? -1;
      });
    }
  }

  Future<void> _toggleFavorite(V2RayConfig config) async {
    final service = Provider.of<V2RayService>(context, listen: false);
    final wasFavorite = config.isFavorite;

    await service.toggleFavorite(config);
    await _loadConfigs();

    if (mounted) {
      await displayInfoBar(
        context,
        builder: (context, close) {
          return InfoBar(
            title: Text(
              wasFavorite ? 'Removed from Favorites' : 'Added to Favorites',
            ),
            content: Text(
              wasFavorite
                  ? '${config.remark} removed from favorites'
                  : '${config.remark} added to favorites',
            ),
            severity: InfoBarSeverity.info,
          );
        },
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _deleteConfig(V2RayConfig config) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Delete Config'),
        content: Text('Are you sure you want to delete "${config.remark}"?'),
        actions: [
          Button(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      if (!mounted) return;
      final service = Provider.of<V2RayService>(context, listen: false);
      final configs = await service.loadConfigs();
      configs.removeWhere((c) => c.id == config.id);
      await service.saveConfigs(configs);
      service.clearPingCache(configId: config.id);

      await _loadConfigs();

      if (mounted) {
        await displayInfoBar(
          context,
          builder: (context, close) {
            return InfoBar(
              title: const Text('Config Deleted'),
              content: Text('${config.remark} has been deleted'),
              severity: InfoBarSeverity.warning,
            );
          },
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  Future<void> _deleteDeadConfigs() async {
    final deadConfigs = _configs.where((config) {
      final ping = _pingResults[config.id];
      return ping == -1;
    }).toList();

    if (deadConfigs.isEmpty) {
      await displayInfoBar(
        context,
        builder: (context, close) {
          return const InfoBar(
            title: Text('No Dead Configs'),
            content: Text('All configs are working fine'),
            severity: InfoBarSeverity.info,
          );
        },
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Delete Dead Configs'),
        content: Text(
          'Found ${deadConfigs.length} dead config(s) with timeout or failed ping.\n\n'
          'Do you want to delete them?',
        ),
        actions: [
          Button(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (result == true) {
      final service = Provider.of<V2RayService>(context, listen: false);
      final configs = await service.loadConfigs();

      final deadIds = deadConfigs.map((c) => c.id).toSet();
      configs.removeWhere((c) => deadIds.contains(c.id));

      await service.saveConfigs(configs);

      for (var config in deadConfigs) {
        service.clearPingCache(configId: config.id);
      }

      await _loadConfigs();
      setState(() {
        _pingResults.clear();
      });

      await displayInfoBar(
        context,
        builder: (context, close) {
          return InfoBar(
            title: const Text('Dead Configs Deleted'),
            content: Text('Deleted ${deadConfigs.length} dead config(s)'),
            severity: InfoBarSeverity.success,
          );
        },
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _copyConfig(V2RayConfig config) async {
    await Clipboard.setData(ClipboardData(text: config.fullConfig));
    if (mounted) {
      await displayInfoBar(
        context,
        builder: (context, close) {
          return InfoBar(
            title: const Text('Config Copied'),
            content: Text('${config.remark} copied to clipboard'),
            severity: InfoBarSeverity.success,
          );
        },
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _showQRCode(V2RayConfig config) async {
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(config.remark),
        content: SizedBox(
          width: 350,
          height: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: config.fullConfig,
                  version: QrVersions.auto,
                  size: 300,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Scan this QR code to import config',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _scanQRCode() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      await displayInfoBar(
        context,
        builder: (context, close) {
          return const InfoBar(
            title: Text('Permission Denied'),
            content: Text('Camera permission is required to scan QR codes'),
            severity: InfoBarSeverity.error,
          );
        },
        duration: const Duration(seconds: 3),
      );
      return;
    }

    await Navigator.push(
      context,
      FluentPageRoute(
        builder: (context) => _QRScannerScreen(
          onQRScanned: (String code) async {
            Navigator.pop(context);
            try {
              final service = Provider.of<V2RayService>(context, listen: false);
              final config = await service.parseConfigFromClipboard(code);
              if (config != null) {
                await _loadConfigs();
                await displayInfoBar(
                  context,
                  builder: (context, close) {
                    return InfoBar(
                      title: const Text('Config Added'),
                      content: Text('${config.remark} added from QR code'),
                      severity: InfoBarSeverity.success,
                    );
                  },
                  duration: const Duration(seconds: 2),
                );
              }
            } catch (e) {
              await displayInfoBar(
                context,
                builder: (context, close) {
                  return InfoBar(
                    title: const Text('Invalid QR Code'),
                    content: Text(e.toString()),
                    severity: InfoBarSeverity.error,
                  );
                },
                duration: const Duration(seconds: 3),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _handleConnect(V2RayConfig config) async {
    final service = Provider.of<V2RayService>(context, listen: false);

    if (service.activeConfig?.id == config.id) {
      await service.disconnect();
      await displayInfoBar(
        context,
        builder: (context, close) {
          return const InfoBar(
            title: Text('Disconnected'),
            severity: InfoBarSeverity.info,
          );
        },
        duration: const Duration(seconds: 2),
      );
    } else {
      if (service.isConnected) {
        await service.disconnect();
      }

      final success = await service.connect(config);
      await displayInfoBar(
        context,
        builder: (context, close) {
          return InfoBar(
            title: Text(success ? 'Connected' : 'Connection Failed'),
            content: Text(
              success
                  ? 'Connected to ${config.remark}'
                  : 'Failed to connect to server',
            ),
            severity: success ? InfoBarSeverity.success : InfoBarSeverity.error,
          );
        },
        duration: const Duration(seconds: 2),
      );
    }
  }
}

class _QRScannerScreen extends StatefulWidget {
  final Function(String) onQRScanned;

  const _QRScannerScreen({required this.onQRScanned});

  @override
  State<_QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<_QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool isScanning = true;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (isScanning) {
      final List<Barcode> barcodes = capture.barcodes;
      for (final barcode in barcodes) {
        if (barcode.rawValue != null) {
          isScanning = false;
          controller.stop();
          widget.onQRScanned(barcode.rawValue!);
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Scan QR Code'),
        leading: IconButton(
          icon: const Icon(FluentIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      content: Stack(
        children: [
          MobileScanner(controller: controller, onDetect: _onDetect),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Position the QR code within the frame',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
