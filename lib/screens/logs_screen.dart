import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluxvpn/services/error_service.dart';
import 'package:fluxvpn/theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final ErrorService _errorService = ErrorService();
  List<File> _logFiles = [];
  bool _isLoading = true;
  String? _selectedLogContent;
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    _loadLogFiles();
  }

  Future<void> _loadLogFiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final files = await _errorService.getLogFiles();
      setState(() {
        _logFiles = files;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _viewLog(File file) async {
    try {
      final content = await file.readAsString();
      setState(() {
        _selectedFile = file;
        _selectedLogContent = content;
      });
    } catch (e) {
      _showErrorDialog('Failed to read log file: $e');
    }
  }

  Future<void> _exportLogs() async {
    try {
      final logs = await _errorService.exportLogs();
      await Clipboard.setData(ClipboardData(text: logs));
      _showSuccessDialog('Logs copied to clipboard');
    } catch (e) {
      _showErrorDialog('Failed to export logs: $e');
    }
  }

  Future<void> _clearAllLogs() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Clear All Logs'),
        content: const Text('Are you sure you want to delete all log files?'),
        actions: [
          Button(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _errorService.clearAllLogs();
      await _loadLogFiles();
      setState(() {
        _selectedFile = null;
        _selectedLogContent = null;
      });
      _showSuccessDialog('All logs cleared');
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: const Text(
          'Application Logs',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        commandBar: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: 'Export Logs',
              child: IconButton(
                icon: const Icon(FluentIcons.export, size: 16),
                onPressed: _exportLogs,
              ),
            ),
            Tooltip(
              message: 'Refresh',
              child: IconButton(
                icon: const Icon(FluentIcons.refresh, size: 16),
                onPressed: _loadLogFiles,
              ),
            ),
            Tooltip(
              message: 'Clear All',
              child: IconButton(
                icon: const Icon(FluentIcons.delete, size: 16),
                onPressed: _clearAllLogs,
              ),
            ),
          ],
        ),
      ),
      content: _isLoading
          ? const Center(child: ProgressRing())
          : Row(
              children: [
                // Left: Log files list
                SizedBox(
                  width: 250,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: _logFiles.isEmpty
                        ? const Center(child: Text('No log files found'))
                        : ListView.builder(
                            itemCount: _logFiles.length,
                            itemBuilder: (context, index) {
                              final file = _logFiles[index];
                              final fileName = file.path
                                  .split(Platform.pathSeparator)
                                  .last;
                              final isSelected =
                                  _selectedFile?.path == file.path;

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.md3Primary.withValues(
                                          alpha: 0.1,
                                        )
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.md3Primary.withValues(
                                            alpha: 0.3,
                                          )
                                        : Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(
                                    fileName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  onPressed: () => _viewLog(file),
                                ),
                              );
                            },
                          ),
                  ),
                ),
                // Right: Log content
                Expanded(
                  child: _selectedLogContent == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                FluentIcons.document_search,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Select a log file to view',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedFile!.path
                                          .split(Platform.pathSeparator)
                                          .last,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      FluentIcons.copy,
                                      size: 16,
                                    ),
                                    onPressed: () async {
                                      await Clipboard.setData(
                                        ClipboardData(
                                          text: _selectedLogContent!,
                                        ),
                                      );
                                      _showSuccessDialog(
                                        'Log content copied to clipboard',
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.withValues(alpha: 0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: SingleChildScrollView(
                                    child: SelectableText(
                                      _selectedLogContent!,
                                      style: const TextStyle(
                                        fontFamily: 'Courier',
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
