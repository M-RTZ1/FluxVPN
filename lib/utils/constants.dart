/// Application-wide constants
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // VPN Connection
  static const vpnFirstAttemptTimeout = Duration(seconds: 8);
  static const vpnSecondAttemptTimeout = Duration(seconds: 12);
  static const vpnRetryBaseDelay = 600; // milliseconds
  static const vpnRetryMaxJitter = 250; // milliseconds
  static const vpnEstablishDelay = Duration(seconds: 1);
  
  // Ping & Network
  static const maxConcurrentPings = 3;
  static const pingCacheDuration = Duration(minutes: 5);
  static const maxPingRetries = 2;
  static const circuitBreakerFailureThreshold = 3;
  static const circuitBreakerBlockDuration = Duration(minutes: 5);
  
  // Statistics
  static const maxStatisticsDataPoints = 60; // 1 minute of data
  static const statisticsUpdateInterval = Duration(seconds: 1);
  static const statisticsNotifyDebounce = Duration(seconds: 2);
  
  // UI & Animation
  static const pulseAnimationDuration = Duration(milliseconds: 2000);
  static const rotateAnimationDuration = Duration(milliseconds: 3000);
  static const defaultAnimationDuration = Duration(milliseconds: 300);
  
  // Storage
  static const logRetentionDays = 7;
  static const maxLogFileSize = 10 * 1024 * 1024; // 10 MB
  
  // Network Timeouts
  static const httpConnectionTimeout = Duration(seconds: 5);
  static const httpRequestTimeout = Duration(seconds: 10);
  static const dnsResolutionTimeout = Duration(seconds: 3);
  
  // Cache
  static const dnsCacheDuration = Duration(hours: 1);
  static const configCacheDuration = Duration(hours: 24);
  
  // Limits
  static const maxConfigsPerSubscription = 1000;
  static const maxSubscriptions = 10;
  static const maxConcurrentDownloads = 3;
}
