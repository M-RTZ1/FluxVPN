// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'FluxVPN';

  @override
  String get appDescription => 'Professional VPN Application';

  @override
  String get home => 'Home';

  @override
  String get servers => 'Servers';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get connect => 'Connect';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get connecting => 'Connecting...';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get tapToConnect => 'TAP TO CONNECT';

  @override
  String get protected => 'PROTECTED';

  @override
  String get upload => 'Upload';

  @override
  String get download => 'Download';

  @override
  String get ping => 'Ping';

  @override
  String get duration => 'Duration';

  @override
  String get testAllServers => 'Test All Servers';

  @override
  String get copyWorkingServers => 'Copy Working Servers';

  @override
  String get deleteDeadServers => 'Delete Dead Servers';

  @override
  String get refresh => 'Refresh';

  @override
  String get importConfig => 'Import Config';

  @override
  String get importWireGuard => 'Import WireGuard';

  @override
  String get scanQRCode => 'Scan QR Code';

  @override
  String get showFavorites => 'Show Favorites';

  @override
  String get showAll => 'Show All';

  @override
  String get manualConfigs => 'Manual Configs';

  @override
  String get subscriptionConfigs => 'Subscription Configs';

  @override
  String get noServers => 'No servers available';

  @override
  String get addServerFirst => 'Add a server first';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get systemDefault => 'System Default';

  @override
  String get speedMode => 'Speed Mode';

  @override
  String get maxSpeed => 'Maximum Speed';

  @override
  String get balanced => 'Balanced';

  @override
  String get batterySaver => 'Battery Saver';

  @override
  String get custom => 'Custom';

  @override
  String get maxSpeedDesc => 'Optimized for YouTube, Netflix and downloads';

  @override
  String get balancedDesc => 'Balance between speed and battery';

  @override
  String get batterySaverDesc => 'Reduce battery consumption';

  @override
  String get statistics => 'Statistics';

  @override
  String get clearStatistics => 'Clear Statistics';

  @override
  String get exportLogs => 'Export Logs';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Information';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String workingServersCopied(int count) {
    return '$count working servers copied';
  }

  @override
  String get noWorkingServers => 'No Working Servers';

  @override
  String get runPingFirst =>
      'Please run Ping All first to find working servers';

  @override
  String get configAdded => 'Config Added';

  @override
  String configAddedSuccess(String name) {
    return '$name added successfully';
  }

  @override
  String get emptyClipboard => 'Empty Clipboard';

  @override
  String get copyConfigFirst => 'Please copy a config first';

  @override
  String get importFailed => 'Import Failed';

  @override
  String get copyFailed => 'Copy Failed';

  @override
  String get deleteConfirm => 'Delete Confirmation';

  @override
  String get deleteMessage => 'Are you sure you want to delete this server?';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get vpnPermissionRequired => 'VPN Permission Required';

  @override
  String get vpnPermissionSteps =>
      '1. Tap Connect button\n2. Allow VPN permission when prompted\n\nIf no dialog appears:\nSettings → Apps → ZedSecure → Permissions';

  @override
  String get version => 'Version';

  @override
  String get developer => 'Developer';

  @override
  String get support => 'Support';

  @override
  String get ms => 'ms';

  @override
  String get seconds => 's';

  @override
  String get minutes => 'm';

  @override
  String get hours => 'h';

  @override
  String get wallpaper => 'Wallpaper';

  @override
  String get wallpaperSettings => 'Wallpaper Settings';

  @override
  String get selectWallpaper => 'Select Wallpaper';

  @override
  String get wallpaperStore => 'Wallpaper Store';

  @override
  String get customWallpaper => 'Custom Wallpaper';

  @override
  String get defaultWallpaper => 'Default Wallpaper';

  @override
  String get wallpaperApplied => 'Wallpaper Applied';

  @override
  String get wallpaperAppliedSuccess => 'Wallpaper applied successfully';

  @override
  String get wallpaperRemoved => 'Wallpaper Removed';

  @override
  String get wallpaperRemovedSuccess => 'Wallpaper removed successfully';

  @override
  String get selectWallpaperFromGallery => 'Select from Gallery';

  @override
  String get wallpaperPreview => 'Preview';

  @override
  String get wallpaperCategory => 'Category';

  @override
  String get wallpaperSize => 'Size';

  @override
  String get wallpaperDownload => 'Download';

  @override
  String get wallpaperDelete => 'Delete';

  @override
  String get wallpaperImportFromGallery => 'Add from Gallery';

  @override
  String get wallpaperAdded => 'Wallpaper imported from gallery';

  @override
  String get wallpaperFavorite => 'Add to Favorites';

  @override
  String get wallpaperUnfavorite => 'Remove from Favorites';

  @override
  String get noWallpapers => 'No wallpapers available';

  @override
  String get wallpaperLoadingError => 'Failed to load wallpapers';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get currentLanguage => 'Current Language';

  @override
  String get english => 'English';

  @override
  String get persian => 'Persian (فارسی)';

  @override
  String get arabic => 'Arabic (العربية)';

  @override
  String get spanish => 'Spanish (Español)';

  @override
  String get french => 'French (Français)';

  @override
  String get german => 'German (Deutsch)';

  @override
  String get russian => 'Russian (Русский)';

  @override
  String get chinese => 'Chinese (中文)';

  @override
  String get japanese => 'Japanese (日本語)';

  @override
  String get korean => 'Korean (한국어)';

  @override
  String get portuguese => 'Portuguese (Português)';

  @override
  String get italian => 'Italian (Italiano)';

  @override
  String get dutch => 'Dutch (Nederlands)';

  @override
  String get turkish => 'Turkish (Türkçe)';

  @override
  String get hindi => 'Hindi (हिन्दी)';

  @override
  String get languageChanged => 'Language Changed';

  @override
  String get languageChangedSuccess => 'Language changed successfully';

  @override
  String get restartAppToApply => 'Restart the app to apply changes';

  @override
  String get autoDetect => 'Auto Detect';

  @override
  String get systemLanguage => 'System Language';
}
