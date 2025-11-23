// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appName => 'FluxVPN';

  @override
  String get appDescription => 'برنامه حرفه‌ای VPN';

  @override
  String get home => 'خانه';

  @override
  String get servers => 'سرورها';

  @override
  String get settings => 'تنظیمات';

  @override
  String get about => 'درباره';

  @override
  String get connect => 'اتصال';

  @override
  String get disconnect => 'قطع اتصال';

  @override
  String get connecting => 'در حال اتصال...';

  @override
  String get connected => 'متصل شد';

  @override
  String get disconnected => 'قطع شد';

  @override
  String get tapToConnect => 'برای اتصال کلیک کنید';

  @override
  String get protected => 'محافظت شده';

  @override
  String get upload => 'آپلود';

  @override
  String get download => 'دانلود';

  @override
  String get ping => 'پینگ';

  @override
  String get duration => 'مدت زمان';

  @override
  String get testAllServers => 'تست همه سرورها';

  @override
  String get copyWorkingServers => 'کپی سرورهای فعال';

  @override
  String get deleteDeadServers => 'حذف سرورهای خراب';

  @override
  String get refresh => 'بروزرسانی';

  @override
  String get importConfig => 'وارد کردن پیکربندی';

  @override
  String get importWireGuard => 'وارد کردن WireGuard';

  @override
  String get scanQRCode => 'اسکن QR کد';

  @override
  String get showFavorites => 'نمایش علاقه‌مندی‌ها';

  @override
  String get showAll => 'نمایش همه';

  @override
  String get manualConfigs => 'پیکربندی‌های دستی';

  @override
  String get subscriptionConfigs => 'پیکربندی‌های اشتراک';

  @override
  String get noServers => 'سروری موجود نیست';

  @override
  String get addServerFirst => 'ابتدا یک سرور اضافه کنید';

  @override
  String get language => 'زبان';

  @override
  String get theme => 'تم';

  @override
  String get darkMode => 'حالت تاریک';

  @override
  String get lightMode => 'حالت روشن';

  @override
  String get systemDefault => 'پیش‌فرض سیستم';

  @override
  String get speedMode => 'حالت سرعت';

  @override
  String get maxSpeed => 'حداکثر سرعت';

  @override
  String get balanced => 'متعادل';

  @override
  String get batterySaver => 'ذخیره باتری';

  @override
  String get custom => 'سفارشی';

  @override
  String get maxSpeedDesc => 'بهینه برای یوتیوب، نتفلیکس و دانلود';

  @override
  String get balancedDesc => 'تعادل بین سرعت و باتری';

  @override
  String get batterySaverDesc => 'کاهش مصرف باتری';

  @override
  String get statistics => 'آمار';

  @override
  String get clearStatistics => 'پاک کردن آمار';

  @override
  String get exportLogs => 'خروجی لاگ‌ها';

  @override
  String get success => 'موفقیت';

  @override
  String get error => 'خطا';

  @override
  String get warning => 'هشدار';

  @override
  String get info => 'اطلاعات';

  @override
  String get copiedToClipboard => 'در کلیپ‌بورد کپی شد';

  @override
  String workingServersCopied(int count) {
    return '$count سرور فعال کپی شد';
  }

  @override
  String get noWorkingServers => 'سرور فعالی وجود ندارد';

  @override
  String get runPingFirst => 'لطفاً ابتدا تست همه سرورها را اجرا کنید';

  @override
  String get configAdded => 'پیکربندی اضافه شد';

  @override
  String configAddedSuccess(String name) {
    return '$name با موفقیت اضافه شد';
  }

  @override
  String get emptyClipboard => 'کلیپ‌بورد خالی است';

  @override
  String get copyConfigFirst => 'لطفاً ابتدا یک پیکربندی کپی کنید';

  @override
  String get importFailed => 'وارد کردن ناموفق بود';

  @override
  String get copyFailed => 'کپی ناموفق بود';

  @override
  String get deleteConfirm => 'تأیید حذف';

  @override
  String get deleteMessage =>
      'آیا مطمئن هستید که می‌خواهید این سرور را حذف کنید؟';

  @override
  String get delete => 'حذف';

  @override
  String get cancel => 'لغو';

  @override
  String get vpnPermissionRequired => 'مجوز VPN مورد نیاز است';

  @override
  String get vpnPermissionSteps =>
      '۱. روی دکمه اتصال کلیک کنید\n۲. مجوز VPN را تأیید کنید\n\nاگر پنجره‌ای ظاهر نشد:\nتنظیمات ← برنامه‌ها ← ZedSecure ← مجوزها';

  @override
  String get version => 'نسخه';

  @override
  String get developer => 'توسعه‌دهنده';

  @override
  String get support => 'پشتیبانی';

  @override
  String get ms => 'میلی‌ثانیه';

  @override
  String get seconds => 'ثانیه';

  @override
  String get minutes => 'دقیقه';

  @override
  String get hours => 'ساعت';

  @override
  String get wallpaper => 'تصویر زمینه';

  @override
  String get wallpaperSettings => 'تنظیمات تصویر زمینه';

  @override
  String get selectWallpaper => 'انتخاب تصویر زمینه';

  @override
  String get wallpaperStore => 'فروشگاه تصویر زمینه';

  @override
  String get customWallpaper => 'تصویر زمینه سفارشی';

  @override
  String get defaultWallpaper => 'تصویر زمینه پیش‌فرض';

  @override
  String get wallpaperApplied => 'تصویر زمینه اعمال شد';

  @override
  String get wallpaperAppliedSuccess => 'تصویر زمینه با موفقیت اعمال شد';

  @override
  String get wallpaperRemoved => 'تصویر زمینه حذف شد';

  @override
  String get wallpaperRemovedSuccess => 'تصویر زمینه با موفقیت حذف شد';

  @override
  String get selectWallpaperFromGallery => 'انتخاب از گالری';

  @override
  String get wallpaperPreview => 'پیش‌نمایش';

  @override
  String get wallpaperCategory => 'دسته‌بندی';

  @override
  String get wallpaperSize => 'اندازه';

  @override
  String get wallpaperDownload => 'دانلود';

  @override
  String get wallpaperDelete => 'حذف';

  @override
  String get wallpaperImportFromGallery => 'افزودن از گالری';

  @override
  String get wallpaperAdded => 'تصویر پس‌زمینه از گالری اضافه شد';

  @override
  String get wallpaperFavorite => 'اضافه به علاقه‌مندی‌ها';

  @override
  String get wallpaperUnfavorite => 'حذف از علاقه‌مندی‌ها';

  @override
  String get noWallpapers => 'تصویر زمینه‌ای موجود نیست';

  @override
  String get wallpaperLoadingError => 'خطا در بارگذاری تصویر زمینه';

  @override
  String get languageSettings => 'تنظیمات زبان';

  @override
  String get selectLanguage => 'انتخاب زبان';

  @override
  String get currentLanguage => 'زبان فعلی';

  @override
  String get english => 'انگلیسی (English)';

  @override
  String get persian => 'فارسی (Persian)';

  @override
  String get arabic => 'عربی (العربية)';

  @override
  String get spanish => 'اسپانیایی (Español)';

  @override
  String get french => 'فرانسوی (Français)';

  @override
  String get german => 'آلمانی (Deutsch)';

  @override
  String get russian => 'روسی (Русский)';

  @override
  String get chinese => 'چینی (中文)';

  @override
  String get japanese => 'ژاپنی (日本語)';

  @override
  String get korean => 'کره‌ای (한국어)';

  @override
  String get portuguese => 'پرتغالی (Português)';

  @override
  String get italian => 'ایتالیایی (Italiano)';

  @override
  String get dutch => 'هلندی (Nederlands)';

  @override
  String get turkish => 'ترکی (Türkçe)';

  @override
  String get hindi => 'هندی (हिन्दी)';

  @override
  String get languageChanged => 'زبان تغییر کرد';

  @override
  String get languageChangedSuccess => 'زبان با موفقیت تغییر کرد';

  @override
  String get restartAppToApply =>
      'برای اعمال تغییرات برنامه را دوباره راه‌اندازی کنید';

  @override
  String get autoDetect => 'تشخیص خودکار';

  @override
  String get systemLanguage => 'زبان سیستم';
}
