import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

/// Centralized error handling and logging service
class ErrorService {
  static final ErrorService _instance = ErrorService._internal();
  factory ErrorService() => _instance;

  late final Logger _logger;
  File? _logFile;
  bool _isInitialized = false;

  ErrorService._internal() {
    _initializeLogger();
  }

  void _initializeLogger() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      level: kDebugMode ? Level.debug : Level.info,
    );
  }

  /// Initialize log file for persistent logging
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');
      
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String().split('T')[0];
      _logFile = File('${logDir.path}/app_$timestamp.log');
      
      _isInitialized = true;
      info('ErrorService initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize ErrorService: $e');
    }
  }

  /// Log debug messages
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
    _writeToFile('DEBUG', message, error, stackTrace);
  }

  /// Log info messages
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
    _writeToFile('INFO', message, error, stackTrace);
  }

  /// Log warning messages
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
    _writeToFile('WARNING', message, error, stackTrace);
  }

  /// Log error messages
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    _writeToFile('ERROR', message, error, stackTrace);
  }

  /// Log fatal errors
  void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
    _writeToFile('FATAL', message, error, stackTrace);
  }

  /// Write log to file
  Future<void> _writeToFile(
    String level,
    String message,
    dynamic error,
    StackTrace? stackTrace,
  ) async {
    if (_logFile == null || !_isInitialized) return;

    try {
      final timestamp = DateTime.now().toIso8601String();
      final logEntry = StringBuffer();
      
      logEntry.writeln('[$timestamp] [$level] $message');
      
      if (error != null) {
        logEntry.writeln('Error: $error');
      }
      
      if (stackTrace != null) {
        logEntry.writeln('StackTrace:\n$stackTrace');
      }
      
      logEntry.writeln('${'=' * 80}\n');

      await _logFile!.writeAsString(
        logEntry.toString(),
        mode: FileMode.append,
      );
    } catch (e) {
      _logger.e('Failed to write to log file: $e');
    }
  }

  /// Handle V2Ray connection errors
  void handleV2RayError(String operation, dynamic error, [StackTrace? stackTrace]) {
    this.error(
      'V2Ray Error during $operation',
      error,
      stackTrace,
    );
  }

  /// Handle subscription parsing errors
  void handleSubscriptionError(String url, dynamic error, [StackTrace? stackTrace]) {
    this.error(
      'Subscription parsing failed for URL: $url',
      error,
      stackTrace,
    );
  }

  /// Handle network errors
  void handleNetworkError(String operation, dynamic error, [StackTrace? stackTrace]) {
    this.error(
      'Network error during $operation',
      error,
      stackTrace,
    );
  }

  /// Handle configuration errors
  void handleConfigError(String configId, dynamic error, [StackTrace? stackTrace]) {
    this.error(
      'Configuration error for config: $configId',
      error,
      stackTrace,
    );
  }

  /// Get user-friendly error message
  String getUserFriendlyMessage(dynamic error) {
    if (error == null) return 'An unknown error occurred';

    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('socket') || 
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Network connection failed. Please check your internet connection.';
    }

    // Timeout errors
    if (errorString.contains('timeout')) {
      return 'Connection timed out. Please try again.';
    }

    // Permission errors
    if (errorString.contains('permission')) {
      return 'Permission denied. Please grant necessary permissions.';
    }

    // V2Ray specific errors
    if (errorString.contains('v2ray') || errorString.contains('vmess')) {
      return 'VPN connection failed. Please check your server configuration.';
    }

    // Subscription errors
    if (errorString.contains('subscription') || errorString.contains('parse')) {
      return 'Failed to load subscription. Please check the URL.';
    }

    // File errors
    if (errorString.contains('file') || errorString.contains('directory')) {
      return 'File operation failed. Please try again.';
    }

    // Default message
    return 'An error occurred. Please try again.';
  }

  /// Clear old log files (keep last 7 days)
  Future<void> clearOldLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');
      
      if (!await logDir.exists()) return;

      final files = await logDir.list().toList();
      final now = DateTime.now();

      for (var file in files) {
        if (file is File) {
          final stat = await file.stat();
          final age = now.difference(stat.modified).inDays;
          
          if (age > 7) {
            await file.delete();
            info('Deleted old log file: ${file.path}');
          }
        }
      }
    } catch (e) {
      _logger.e('Failed to clear old logs: $e');
    }
  }

  /// Get all log files
  Future<List<File>> getLogFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');
      
      if (!await logDir.exists()) return [];

      final files = await logDir.list().toList();
      return files.whereType<File>().toList();
    } catch (e) {
      _logger.e('Failed to get log files: $e');
      return [];
    }
  }

  /// Export logs as string
  Future<String> exportLogs() async {
    try {
      final files = await getLogFiles();
      final buffer = StringBuffer();

      for (var file in files) {
        buffer.writeln('=== ${file.path} ===');
        buffer.writeln(await file.readAsString());
        buffer.writeln();
      }

      return buffer.toString();
    } catch (e) {
      _logger.e('Failed to export logs: $e');
      return 'Failed to export logs: $e';
    }
  }

  /// Clear all logs
  Future<void> clearAllLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');
      
      if (await logDir.exists()) {
        await logDir.delete(recursive: true);
        await logDir.create();
        info('All logs cleared');
      }
    } catch (e) {
      _logger.e('Failed to clear logs: $e');
    }
  }
}
