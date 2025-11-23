import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:fluxvpn/services/wireguard_service.dart';
import 'package:fluxvpn/services/wireguard_parser_service.dart';
import 'package:fluxvpn/services/theme_service.dart';
import 'package:fluxvpn/models/wireguard_config.dart';
import 'package:fluxvpn/theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

class WireGuardScreen extends StatefulWidget {
  const WireGuardScreen({super.key});

  @override
  State<WireGuardScreen> createState() => _WireGuardScreenState();
}

class _WireGuardScreenState extends State<WireGuardScreen> {
  List<WireGuardConfig> _configs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfigs();
  }

  Future<void> _loadConfigs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final wgService = Provider.of<WireGuardService>(context, listen: false);
      final configs = await wgService.loadConfigs();
      setState(() {
        _configs = configs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _importFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData('text/plain');
      final content = clipboardData?.text;

      if (content == null || content.isEmpty) {
        _showError('Clipboard is empty');
        return;
      }

      if (!WireGuardParserService.validateConfig(content)) {
        _showError('Invalid WireGuard config format');
        return;
      }

      _showImportDialog(content);
    } catch (e) {
      _showError('Failed to import from clipboard: $e');
    }
  }

  String _normalizeConfigContent(String content) {
    // Remove BOM if present
    if (content.startsWith('\ufeff')) {
      content = content.substring(1);
    }

    // Convert CRLF to LF
    content = content.replaceAll('\r\n', '\n');

    // Remove any remaining CR
    content = content.replaceAll('\r', '\n');

    // Trim whitespace
    content = content.trim();

    return content;
  }

  Future<void> _testImportSampleConfig() async {
    print('🧪 Testing sample WireGuard config import...');

    // Sample config from privado.ams-032.conf
    const sampleConfig = '''[Interface]
PrivateKey = mAH/kSlY9EGS/u+gh6aNidnYVRqiEGT29b/47G3RAn8=
Address = 100.64.103.177/32
DNS = 198.18.0.1,198.18.0.2

[Peer]
PublicKey = KgTUh3KLijVluDvNpzDCJJfrJ7EyLzYLmdHCksG4sRg=
AllowedIPs = 0.0.0.0/0
Endpoint = 91.148.240.47:51820
''';

    try {
      print('📝 Sample config length: ${sampleConfig.length} chars');

      // Normalize
      final normalized = _normalizeConfigContent(sampleConfig);
      print('🔧 Normalized length: ${normalized.length} chars');

      // Validate
      if (!WireGuardParserService.validateConfig(normalized)) {
        print('❌ Validation failed');
        _showError('Sample config validation failed. Check console.');
        return;
      }

      print('✅ Validation passed');
      _showImportDialog(normalized, defaultName: 'Test-Amsterdam-032');
    } catch (e, stackTrace) {
      print('❌ Test import error: $e');
      print('Stack trace: $stackTrace');
      _showError('Test import failed: $e');
    }
  }

  Future<void> _importFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;
      print('📁 Selected file: ${file.name}');
      print('📂 File path: ${file.path}');
      print('📊 File size: ${file.size} bytes');

      final fileNameLower = file.name.toLowerCase();
      if (!(fileNameLower.endsWith('.conf') || fileNameLower.endsWith('.wg'))) {
        _showError('Please select a .conf or .wg file');
        return;
      }

      String? content;
      if (file.bytes != null) {
        content = String.fromCharCodes(file.bytes!);
        print('✅ Read from bytes: ${content.length} chars');
      } else if (file.path != null) {
        content = await File(file.path!).readAsString();
        print('✅ Read from path: ${content.length} chars');
      }

      if (content == null || content.isEmpty) {
        _showError('Selected file is empty');
        return;
      }

      // Normalize content
      content = _normalizeConfigContent(content);
      print('🔧 Normalized content: ${content.length} chars');

      // Show first 300 chars for debugging
      final preview = content.length > 300
          ? content.substring(0, 300)
          : content;
      print('📝 Content preview:\n$preview\n...');

      if (!WireGuardParserService.validateConfig(content)) {
        print('❌ Validation failed');
        _showError(
          'Invalid WireGuard config format. Check console for details.',
        );
        return;
      }

      print('✅ Validation passed');
      final defaultName = file.name.isNotEmpty
          ? file.name
                .replaceAll(RegExp(r'\.conf$', caseSensitive: false), '')
                .replaceAll(RegExp(r'\.wg$', caseSensitive: false), '')
          : 'WireGuard Config';
      _showImportDialog(content, defaultName: defaultName);
    } catch (e, stackTrace) {
      print('❌ Import error: $e');
      print('Stack trace: $stackTrace');
      _showError('Failed to import file: $e');
    }
  }

  void _showImportDialog(
    String content, {
    String defaultName = 'WireGuard Config',
  }) {
    final nameController = TextEditingController(text: defaultName);

    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Import WireGuard Config'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Config Name:'),
            const SizedBox(height: 8),
            TextBox(
              controller: nameController,
              placeholder: 'Enter config name',
            ),
          ],
        ),
        actions: [
          Button(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _importConfig(content, nameController.text);
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  Future<void> _importConfig(String content, String name) async {
    try {
      final wgService = Provider.of<WireGuardService>(context, listen: false);
      final config = WireGuardParserService.parseConfig(content, name: name);

      await wgService.saveConfig(config);
      await _loadConfigs();

      _showSuccess('Config imported successfully');
    } catch (e) {
      _showError('Failed to import config: $e');
    }
  }

  Future<void> _deleteConfig(WireGuardConfig config) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Delete Config'),
        content: Text('Are you sure you want to delete "${config.name}"?'),
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
      final wgService = Provider.of<WireGuardService>(context, listen: false);
      await wgService.deleteConfig(config.id);
      await _loadConfigs();
      _showSuccess('Config deleted');
    }
  }

  Future<void> _connectConfig(WireGuardConfig config) async {
    try {
      final wgService = Provider.of<WireGuardService>(context, listen: false);

      if (wgService.isConnected) {
        _showError('Please disconnect current connection first');
        return;
      }

      if (wgService.isConnecting) {
        _showError('Connection already in progress');
        return;
      }

      final success = await wgService.connect(config);

      if (success) {
        if (mounted) {
          _showSuccess('Connected to ${config.name}');
        }
      } else {
        if (mounted) {
          _showError(
            'Connection failed. If you denied VPN permission, please go to:\nSettings → Apps → FluxVPN → Permissions\nand enable VPN access.',
          );
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        if (errorMsg.contains('permission') ||
            errorMsg.contains('Permission')) {
          await showDialog(
            context: context,
            builder: (context) => ContentDialog(
              title: const Text('VPN Permission Required'),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('VPN permission is required to connect.'),
                  SizedBox(height: 12),
                  Text(
                    'Please go to:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Settings → Apps → FluxVPN → Permissions'),
                  SizedBox(height: 8),
                  Text('Then enable VPN access and try again.'),
                ],
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          _showError('Connection failed: $errorMsg');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Unexpected error: ${e.toString()}');
      }
    }
  }

  Future<void> _testPingConfig(WireGuardConfig config) async {
    try {
      final wgService = Provider.of<WireGuardService>(context, listen: false);

      final isHealthy = await wgService.checkWireGuardHealth(config);
      if (!mounted) return;

      if (isHealthy) {
        _showSuccess(
          'WireGuard tunnel for ${config.name} is healthy (handshake OK).',
        );
      } else {
        _showError(
          'WireGuard tunnel for ${config.name} is not healthy.\n'
          'Make sure it is connected and the server is reachable.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to test WireGuard health: $e');
    }
  }

  Future<void> _viewConfigDetails(WireGuardConfig config) async {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(config.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem(
                'Interface Address',
                config.interface.addresses.join(', '),
              ),
              _buildDetailItem('DNS', config.interface.dns.join(', ')),
              _buildDetailItem('MTU', config.interface.mtu.toString()),
              const SizedBox(height: 16),
              const Text(
                'Peer:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildDetailItem('Endpoint', config.peers.first.endpoint),
              _buildDetailItem(
                'Allowed IPs',
                config.peers.first.allowedIPs.join(', '),
              ),
              _buildDetailItem(
                'Keepalive',
                '${config.peers.first.persistentKeepalive}s',
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

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    displayInfoBar(
      context,
      builder: (context, close) {
        return InfoBar(
          title: const Text('Success'),
          content: Text(message),
          severity: InfoBarSeverity.success,
        );
      },
      duration: const Duration(seconds: 2),
    );
  }

  void _showError(String message) {
    displayInfoBar(
      context,
      builder: (context, close) {
        return InfoBar(
          title: const Text('Error'),
          content: Text(message),
          severity: InfoBarSeverity.error,
        );
      },
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;

    return ScaffoldPage(
      header: PageHeader(
        title: const Text(
          'WireGuard',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        commandBar: Wrap(
          spacing: 4,
          children: [
            Tooltip(
              message: 'Import from Clipboard',
              child: IconButton(
                icon: const Icon(FluentIcons.paste, size: 16),
                onPressed: _importFromClipboard,
              ),
            ),
            Tooltip(
              message: 'Import from File',
              child: IconButton(
                icon: const Icon(FluentIcons.folder_open, size: 16),
                onPressed: _importFromFile,
              ),
            ),
            Tooltip(
              message: 'Test Import (Debug)',
              child: IconButton(
                icon: const Icon(FluentIcons.test_beaker, size: 16),
                onPressed: _testImportSampleConfig,
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
      content: _isLoading
          ? const Center(child: ProgressRing())
          : _configs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FluentIcons.network_tower, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No WireGuard configs',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Import a config from clipboard',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton(
                        onPressed: _importFromClipboard,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(FluentIcons.paste, size: 16),
                            SizedBox(width: 8),
                            Text('Import from Clipboard'),
                          ],
                        ),
                      ),
                      Button(
                        onPressed: _importFromFile,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(FluentIcons.folder_open, size: 16),
                            SizedBox(width: 8),
                            Text('Import from File'),
                          ],
                        ),
                      ),
                      Button(
                        onPressed: _testImportSampleConfig,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(FluentIcons.test_beaker, size: 16),
                            SizedBox(width: 8),
                            Text('Test Sample Config'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : Consumer<WireGuardService>(
              builder: (context, wgService, child) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _configs.length,
                  itemBuilder: (context, index) {
                    final config = _configs[index];
                    final isActive = wgService.activeConfig?.id == config.id;
                    final isSelected =
                        wgService.selectedConfig?.id == config.id;

                    return GestureDetector(
                      onTap: () => wgService.selectConfig(config),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.md3Primary.withOpacity(0.12),
                              AppTheme.md3Primary.withOpacity(0.04),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive
                                ? AppTheme.md3Success.withOpacity(0.5)
                                : isSelected
                                ? AppTheme.md3Primary.withOpacity(0.6)
                                : AppTheme.md3Primary.withOpacity(0.2),
                            width: isActive
                                ? 2
                                : isSelected
                                ? 1.8
                                : 1.3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.md3Primary.withOpacity(0.1),
                              blurRadius: 16,
                              spreadRadius: 1,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.md3Primary.withOpacity(0.4),
                                      AppTheme.md3Primary.withOpacity(0.15),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppTheme.md3Primary.withOpacity(
                                      0.25,
                                    ),
                                    width: 1.2,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    FluentIcons.network_tower,
                                    color: AppTheme.md3Primary,
                                    size: 30,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            config.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black,
                                              letterSpacing: 0.2,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isActive) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.md3Success
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'ACTIVE',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.md3Success,
                                              ),
                                            ),
                                          ),
                                        ] else if (isSelected) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.md3Primary
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'SELECTED',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.md3Primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '🌐 ${config.peers.first.endpoint}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.withOpacity(0.8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (isActive) ...[
                                Tooltip(
                                  message: 'Test Ping / Health',
                                  child: IconButton(
                                    icon: const Icon(
                                      FluentIcons.test_beaker,
                                      size: 18,
                                    ),
                                    onPressed: () => _testPingConfig(config),
                                  ),
                                ),
                              ] else ...[
                                Tooltip(
                                  message: 'Connect',
                                  child: IconButton(
                                    icon: const Icon(
                                      FluentIcons.plug_connected,
                                      size: 18,
                                    ),
                                    onPressed: () => _connectConfig(config),
                                  ),
                                ),
                                Tooltip(
                                  message: 'Details',
                                  child: IconButton(
                                    icon: const Icon(
                                      FluentIcons.info,
                                      size: 18,
                                    ),
                                    onPressed: () => _viewConfigDetails(config),
                                  ),
                                ),
                                Tooltip(
                                  message: 'Delete',
                                  child: IconButton(
                                    icon: Icon(
                                      FluentIcons.delete,
                                      size: 18,
                                      color: AppTheme.disconnectedRed,
                                    ),
                                    onPressed: () => _deleteConfig(config),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
