import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fa'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'FluxVPN'**
  String get appName;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Professional VPN Application'**
  String get appDescription;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @servers.
  ///
  /// In en, this message translates to:
  /// **'Servers'**
  String get servers;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @tapToConnect.
  ///
  /// In en, this message translates to:
  /// **'TAP TO CONNECT'**
  String get tapToConnect;

  /// No description provided for @protected.
  ///
  /// In en, this message translates to:
  /// **'PROTECTED'**
  String get protected;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @ping.
  ///
  /// In en, this message translates to:
  /// **'Ping'**
  String get ping;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @testAllServers.
  ///
  /// In en, this message translates to:
  /// **'Test All Servers'**
  String get testAllServers;

  /// No description provided for @copyWorkingServers.
  ///
  /// In en, this message translates to:
  /// **'Copy Working Servers'**
  String get copyWorkingServers;

  /// No description provided for @deleteDeadServers.
  ///
  /// In en, this message translates to:
  /// **'Delete Dead Servers'**
  String get deleteDeadServers;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @importConfig.
  ///
  /// In en, this message translates to:
  /// **'Import Config'**
  String get importConfig;

  /// No description provided for @importWireGuard.
  ///
  /// In en, this message translates to:
  /// **'Import WireGuard'**
  String get importWireGuard;

  /// No description provided for @scanQRCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQRCode;

  /// No description provided for @showFavorites.
  ///
  /// In en, this message translates to:
  /// **'Show Favorites'**
  String get showFavorites;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show All'**
  String get showAll;

  /// No description provided for @manualConfigs.
  ///
  /// In en, this message translates to:
  /// **'Manual Configs'**
  String get manualConfigs;

  /// No description provided for @subscriptionConfigs.
  ///
  /// In en, this message translates to:
  /// **'Subscription Configs'**
  String get subscriptionConfigs;

  /// No description provided for @noServers.
  ///
  /// In en, this message translates to:
  /// **'No servers available'**
  String get noServers;

  /// No description provided for @addServerFirst.
  ///
  /// In en, this message translates to:
  /// **'Add a server first'**
  String get addServerFirst;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @speedMode.
  ///
  /// In en, this message translates to:
  /// **'Speed Mode'**
  String get speedMode;

  /// No description provided for @maxSpeed.
  ///
  /// In en, this message translates to:
  /// **'Maximum Speed'**
  String get maxSpeed;

  /// No description provided for @balanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get balanced;

  /// No description provided for @batterySaver.
  ///
  /// In en, this message translates to:
  /// **'Battery Saver'**
  String get batterySaver;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @maxSpeedDesc.
  ///
  /// In en, this message translates to:
  /// **'Optimized for YouTube, Netflix and downloads'**
  String get maxSpeedDesc;

  /// No description provided for @balancedDesc.
  ///
  /// In en, this message translates to:
  /// **'Balance between speed and battery'**
  String get balancedDesc;

  /// No description provided for @batterySaverDesc.
  ///
  /// In en, this message translates to:
  /// **'Reduce battery consumption'**
  String get batterySaverDesc;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @clearStatistics.
  ///
  /// In en, this message translates to:
  /// **'Clear Statistics'**
  String get clearStatistics;

  /// No description provided for @exportLogs.
  ///
  /// In en, this message translates to:
  /// **'Export Logs'**
  String get exportLogs;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get info;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @workingServersCopied.
  ///
  /// In en, this message translates to:
  /// **'{count} working servers copied'**
  String workingServersCopied(int count);

  /// No description provided for @noWorkingServers.
  ///
  /// In en, this message translates to:
  /// **'No Working Servers'**
  String get noWorkingServers;

  /// No description provided for @runPingFirst.
  ///
  /// In en, this message translates to:
  /// **'Please run Ping All first to find working servers'**
  String get runPingFirst;

  /// No description provided for @configAdded.
  ///
  /// In en, this message translates to:
  /// **'Config Added'**
  String get configAdded;

  /// No description provided for @configAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} added successfully'**
  String configAddedSuccess(String name);

  /// No description provided for @emptyClipboard.
  ///
  /// In en, this message translates to:
  /// **'Empty Clipboard'**
  String get emptyClipboard;

  /// No description provided for @copyConfigFirst.
  ///
  /// In en, this message translates to:
  /// **'Please copy a config first'**
  String get copyConfigFirst;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import Failed'**
  String get importFailed;

  /// No description provided for @copyFailed.
  ///
  /// In en, this message translates to:
  /// **'Copy Failed'**
  String get copyFailed;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Confirmation'**
  String get deleteConfirm;

  /// No description provided for @deleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this server?'**
  String get deleteMessage;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @vpnPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'VPN Permission Required'**
  String get vpnPermissionRequired;

  /// No description provided for @vpnPermissionSteps.
  ///
  /// In en, this message translates to:
  /// **'1. Tap Connect button\n2. Allow VPN permission when prompted\n\nIf no dialog appears:\nSettings → Apps → ZedSecure → Permissions'**
  String get vpnPermissionSteps;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @ms.
  ///
  /// In en, this message translates to:
  /// **'ms'**
  String get ms;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get seconds;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get minutes;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get hours;

  /// No description provided for @wallpaper.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper'**
  String get wallpaper;

  /// No description provided for @wallpaperSettings.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper Settings'**
  String get wallpaperSettings;

  /// No description provided for @selectWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Select Wallpaper'**
  String get selectWallpaper;

  /// No description provided for @wallpaperStore.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper Store'**
  String get wallpaperStore;

  /// No description provided for @customWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Custom Wallpaper'**
  String get customWallpaper;

  /// No description provided for @defaultWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Default Wallpaper'**
  String get defaultWallpaper;

  /// No description provided for @wallpaperApplied.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper Applied'**
  String get wallpaperApplied;

  /// No description provided for @wallpaperAppliedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper applied successfully'**
  String get wallpaperAppliedSuccess;

  /// No description provided for @wallpaperRemoved.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper Removed'**
  String get wallpaperRemoved;

  /// No description provided for @wallpaperRemovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper removed successfully'**
  String get wallpaperRemovedSuccess;

  /// No description provided for @selectWallpaperFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select from Gallery'**
  String get selectWallpaperFromGallery;

  /// No description provided for @wallpaperPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get wallpaperPreview;

  /// No description provided for @wallpaperCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get wallpaperCategory;

  /// No description provided for @wallpaperSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get wallpaperSize;

  /// No description provided for @wallpaperDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get wallpaperDownload;

  /// No description provided for @wallpaperDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get wallpaperDelete;

  /// No description provided for @wallpaperImportFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Add from Gallery'**
  String get wallpaperImportFromGallery;

  /// No description provided for @wallpaperAdded.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper imported from gallery'**
  String get wallpaperAdded;

  /// No description provided for @wallpaperFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get wallpaperFavorite;

  /// No description provided for @wallpaperUnfavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get wallpaperUnfavorite;

  /// No description provided for @noWallpapers.
  ///
  /// In en, this message translates to:
  /// **'No wallpapers available'**
  String get noWallpapers;

  /// No description provided for @wallpaperLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load wallpapers'**
  String get wallpaperLoadingError;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current Language'**
  String get currentLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @persian.
  ///
  /// In en, this message translates to:
  /// **'Persian (فارسی)'**
  String get persian;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic (العربية)'**
  String get arabic;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish (Español)'**
  String get spanish;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French (Français)'**
  String get french;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German (Deutsch)'**
  String get german;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Russian (Русский)'**
  String get russian;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese (中文)'**
  String get chinese;

  /// No description provided for @japanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese (日本語)'**
  String get japanese;

  /// No description provided for @korean.
  ///
  /// In en, this message translates to:
  /// **'Korean (한국어)'**
  String get korean;

  /// No description provided for @portuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese (Português)'**
  String get portuguese;

  /// No description provided for @italian.
  ///
  /// In en, this message translates to:
  /// **'Italian (Italiano)'**
  String get italian;

  /// No description provided for @dutch.
  ///
  /// In en, this message translates to:
  /// **'Dutch (Nederlands)'**
  String get dutch;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish (Türkçe)'**
  String get turkish;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi (हिन्दी)'**
  String get hindi;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language Changed'**
  String get languageChanged;

  /// No description provided for @languageChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully'**
  String get languageChangedSuccess;

  /// No description provided for @restartAppToApply.
  ///
  /// In en, this message translates to:
  /// **'Restart the app to apply changes'**
  String get restartAppToApply;

  /// No description provided for @autoDetect.
  ///
  /// In en, this message translates to:
  /// **'Auto Detect'**
  String get autoDetect;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'System Language'**
  String get systemLanguage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
