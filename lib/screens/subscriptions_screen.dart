import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:fluxvpn/services/v2ray_service.dart';
import 'package:fluxvpn/services/theme_service.dart';
import 'package:fluxvpn/models/subscription.dart';
import 'package:fluxvpn/theme/app_theme.dart';
import 'package:fluxvpn/services/error_service.dart'; // Import ErrorService

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  List<Subscription> _subscriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    setState(() {
      _isLoading = true;
    });

    final service = Provider.of<V2RayService>(context, listen: false);
    final subs = await service.loadSubscriptions();

    // Remove legacy suggested subscription if it still exists in storage
    final filteredSubs = subs.where((sub) {
      final normalizedId = sub.id.toLowerCase();
      final normalizedName = sub.name.toLowerCase();
      return !normalizedId.contains('suggested_cloudflare_plus') &&
          !normalizedName.contains('suggested - cloudflare');
    }).toList();

    if (filteredSubs.length != subs.length) {
      await service.saveSubscriptions(filteredSubs);
    }

    setState(() {
      _subscriptions = filteredSubs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;

    return ScaffoldPage(
      header: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0A0E27), const Color(0xFF1A1F3A)]
                : [const Color(0xFFF5F7FA), const Color(0xFFEBEEF5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 14,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
          ],
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: PageHeader(
          title: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(FluentIcons.cloud, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 16),
              const Flexible(
                child: Text(
                  'Subscriptions',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          commandBar: FilledButton(
            style: ButtonStyle(
              backgroundColor: ButtonState.all(
                Color(0x1FFFFFFF),
              ), // شفاف معادل Colors.white12
            ),
            onPressed: _showAddSubscriptionDialog,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FluentIcons.add, size: 18, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Add Subscription',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      content: _isLoading
          ? const Center(child: ProgressRing())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF0A0E27), const Color(0xFF1A1F3A)]
                      : [const Color(0xFFF5F7FA), const Color(0xFFEBEEF5)],
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                children: [
                  if (_subscriptions.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppTheme.md3Primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Active Subscriptions (${_subscriptions.length})',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ..._subscriptions.map(
                      (sub) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildSubscriptionCard(sub),
                      ),
                    ),
                  ],
                  if (_subscriptions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.md3Primary.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  FluentIcons.cloud,
                                  size: 40,
                                  color: AppTheme.md3Primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'No Subscriptions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add your first subscription to get started',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildSubscriptionCard(Subscription subscription) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withValues(alpha: 0.15),
            AppTheme.primaryBlue.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withValues(alpha: 0.5),
                    AppTheme.primaryBlue.withValues(alpha: 0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  FluentIcons.cloud,
                  color: AppTheme.primaryBlue,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscription.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        FluentIcons.server,
                        size: 14,
                        color: Colors.grey.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${subscription.configCount} servers',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        FluentIcons.clock,
                        size: 14,
                        color: Colors.grey.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(subscription.lastUpdate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.md3Primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Tooltip(
                message: 'Refresh',
                child: IconButton(
                  icon: Icon(
                    FluentIcons.refresh,
                    size: 18,
                    color: AppTheme.md3Primary,
                  ),
                  onPressed: () => _updateSubscription(subscription),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.disconnectedRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Tooltip(
                message: 'Delete',
                child: IconButton(
                  icon: Icon(
                    FluentIcons.delete,
                    size: 18,
                    color: AppTheme.disconnectedRed,
                  ),
                  onPressed: () => _deleteSubscription(subscription),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _showAddSubscriptionDialog() async {
    final nameController = TextEditingController();
    final urlController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Add Subscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Name'),
            const SizedBox(height: 8),
            TextBox(controller: nameController, placeholder: 'My Subscription'),
            const SizedBox(height: 16),
            const Text('URL'),
            const SizedBox(height: 8),
            TextBox(controller: urlController, placeholder: 'https://...'),
          ],
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
              if (nameController.text.isEmpty || urlController.text.isEmpty) {
                return;
              }

              Navigator.pop(context);

              final service = Provider.of<V2RayService>(context, listen: false);

              try {
                final configs = await service.parseSubscriptionUrl(
                  urlController.text,
                );

                final existingConfigs = await service.loadConfigs();

                final existingFullConfigs = existingConfigs
                    .map((c) => c.fullConfig)
                    .toSet();
                final newConfigs = configs
                    .where(
                      (config) =>
                          !existingFullConfigs.contains(config.fullConfig),
                    )
                    .toList();

                final allConfigs = [...existingConfigs, ...newConfigs];
                await service.saveConfigs(allConfigs);

                final subscription = Subscription(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  url: urlController.text,
                  lastUpdate: DateTime.now(),
                  configCount: newConfigs.length,
                );

                _subscriptions.add(subscription);
                await service.saveSubscriptions(_subscriptions);
                await _loadSubscriptions();

                if (mounted) {
                  await displayInfoBar(
                    context,
                    builder: (context, close) {
                      return InfoBar(
                        title: const Text('Success'),
                        content: Text('Added ${newConfigs.length} new servers'),
                        severity: InfoBarSeverity.success,
                      );
                    },
                    duration: const Duration(seconds: 3),
                  );
                }
              } catch (e) {
                if (mounted) {
                  await displayInfoBar(
                    context,
                    builder: (context, close) {
                      return InfoBar(
                        title: const Text('Error'),
                        content: Text(e.toString()),
                        severity: InfoBarSeverity.error,
                      );
                    },
                    duration: const Duration(seconds: 3),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateSubscription(Subscription subscription) async {
    final service = Provider.of<V2RayService>(context, listen: false);

    try {
      final configs = await service.parseSubscriptionUrl(subscription.url);

      final existingConfigs = await service.loadConfigs();
      final filteredConfigs = existingConfigs.where((config) {
        return !configs.any(
          (newConfig) => newConfig.fullConfig == config.fullConfig,
        );
      }).toList();

      final allConfigs = [...filteredConfigs, ...configs];
      await service.saveConfigs(allConfigs);

      final updatedSub = subscription.copyWith(
        lastUpdate: DateTime.now(),
        configCount: configs.length,
      );

      final index = _subscriptions.indexWhere((s) => s.id == subscription.id);
      if (index != -1) {
        _subscriptions[index] = updatedSub;
      }

      await service.saveSubscriptions(_subscriptions);
      await _loadSubscriptions();

      if (mounted) {
        await displayInfoBar(
          context,
          builder: (context, close) {
            return InfoBar(
              title: const Text('Updated'),
              content: Text('Updated ${configs.length} servers'),
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
              title: const Text('Error'),
              content: Text(e.toString()),
              severity: InfoBarSeverity.error,
            );
          },
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  Future<void> _deleteSubscription(Subscription subscription) async {
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Delete Subscription'),
        content: Text(
          'Are you sure you want to delete "${subscription.name}"?',
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

              try {
                _subscriptions.removeWhere((s) => s.id == subscription.id);
                final service = Provider.of<V2RayService>(
                  context,
                  listen: false,
                );
                await service.saveSubscriptions(_subscriptions);
                await _loadSubscriptions();

                if (mounted) {
                  await displayInfoBar(
                    context,
                    builder: (context, close) {
                      return const InfoBar(
                        title: Text('Deleted'),
                        severity: InfoBarSeverity.info,
                      );
                    },
                    duration: const Duration(seconds: 2),
                  );
                }
              } catch (e) {
                final errorService = Provider.of<ErrorService>(
                  context,
                  listen: false,
                );
                errorService.error('Failed to delete subscription: $e');
                if (mounted) {
                  await displayInfoBar(
                    context,
                    builder: (context, close) {
                      return InfoBar(
                        title: const Text('Error'),
                        content: Text('Failed to delete subscription: $e'),
                        severity: InfoBarSeverity.error,
                      );
                    },
                    duration: const Duration(seconds: 3),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
