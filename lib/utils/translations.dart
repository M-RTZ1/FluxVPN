import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluxvpn/services/localization_service.dart';

/// Simple translation helper for quick implementation
class Translations {
  static final Map<String, Map<String, String>> _translations = {
    // Navigation
    'Home': {'fa': 'خانه'},
    'Servers': {'fa': 'سرورها'},
    'Subscriptions': {'fa': 'اشتراک‌ها'},
    'Settings': {'fa': 'تنظیمات'},

    // Connection
    'Connect': {'fa': 'اتصال'},
    'Disconnect': {'fa': 'قطع اتصال'},
    'Connecting...': {'fa': 'در حال اتصال...'},
    'Connected': {'fa': 'متصل شد'},
    'Disconnected': {'fa': 'قطع شد'},
    'TAP TO CONNECT': {'fa': 'برای اتصال کلیک کنید'},
    'PROTECTED': {'fa': 'محافظت شده'},

    // Stats
    'Upload': {'fa': 'آپلود'},
    'Download': {'fa': 'دانلود'},
    'Ping': {'fa': 'پینگ'},
    'Duration': {'fa': 'مدت زمان'},

    // Servers Screen
    'Test All Servers': {'fa': 'تست همه سرورها'},
    'Copy Working Servers': {'fa': 'کپی سرورهای فعال'},
    'Delete Dead Servers': {'fa': 'حذف سرورهای خراب'},
    'Refresh': {'fa': 'بروزرسانی'},
    'Import V2Ray Config': {'fa': 'وارد کردن پیکربندی'},
    'Import WireGuard Config': {'fa': 'وارد کردن WireGuard'},
    'Scan QR Code': {'fa': 'اسکن QR کد'},
    'Show Favorites Only': {'fa': 'فقط علاقه‌مندی‌ها'},
    'Show All Servers': {'fa': 'نمایش همه'},

    'Manual Configs': {'fa': 'پیکربندی‌های دستی'},
    'Subscription Configs': {'fa': 'پیکربندی‌های اشتراک'},
    'No servers available': {'fa': 'سروری موجود نیست'},
    'Add a server first': {'fa': 'ابتدا یک سرور اضافه کنید'},

    // Settings
    'Language / زبان': {'fa': 'Language / زبان'},
    'Dark Mode': {'fa': 'حالت تاریک'},
    'Using dark theme': {'fa': 'استفاده از تم تاریک'},
    'Using light theme': {'fa': 'استفاده از تم روشن'},
    'Appearance': {'fa': 'ظاهر'},
    'Network': {'fa': 'شبکه'},
    'Data': {'fa': 'داده'},
    'About': {'fa': 'درباره'},
    'Updates': {'fa': 'بروزرسانی‌ها'},
    'Check for Updates': {'fa': 'بررسی بروزرسانی'},
    'Download Update': {'fa': 'دانلود بروزرسانی'},
    'New version available': {'fa': 'نسخه جدید موجود است'},
    'You are up to date': {'fa': 'برنامه به‌روز است'},
    'Current version': {'fa': 'نسخه فعلی'},
    'Latest version': {'fa': 'آخرین نسخه'},
    'Release Notes': {'fa': 'یادداشت نسخه'},

    'DNS Settings': {'fa': 'تنظیمات DNS'},
    'Configure custom DNS servers': {'fa': 'تنظیم سرورهای DNS سفارشی'},
    'Backup Configs': {'fa': 'پشتیبان‌گیری'},
    'Export all configs to Downloads': {'fa': 'خروجی همه پیکربندی‌ها'},
    'Restore Configs': {'fa': 'بازیابی پیکربندی‌ها'},
    'Import configs from backup file': {'fa': 'وارد کردن از فایل پشتیبان'},
    'Clear Statistics': {'fa': 'پاک کردن آمار'},
    'Reset all statistics data': {'fa': 'بازنشانی تمام داده‌های آماری'},
    'Export Logs': {'fa': 'خروجی لاگ‌ها'},
    'Export application logs': {'fa': 'خروجی لاگ‌های برنامه'},

    // Messages
    'Success': {'fa': 'موفقیت'},
    'Error': {'fa': 'خطا'},
    'Warning': {'fa': 'هشدار'},
    'Info': {'fa': 'اطلاعات'},

    'Copied to clipboard': {'fa': 'در کلیپ‌بورد کپی شد'},
    'No Working Servers': {'fa': 'سرور فعالی وجود ندارد'},
    'Please run Ping All first to find working servers': {
      'fa': 'لطفاً ابتدا تست همه سرورها را اجرا کنید',
    },

    'Config Added': {'fa': 'پیکربندی اضافه شد'},
    'added successfully': {'fa': 'با موفقیت اضافه شد'},

    'Empty Clipboard': {'fa': 'کلیپ‌بورد خالی است'},
    'Please copy a config first': {'fa': 'لطفاً ابتدا یک پیکربندی کپی کنید'},

    'Import Failed': {'fa': 'وارد کردن ناموفق بود'},
    'Copy Failed': {'fa': 'کپی ناموفق بود'},

    'Delete Confirmation': {'fa': 'تأیید حذف'},
    'Are you sure you want to delete this server?': {
      'fa': 'آیا مطمئن هستید که می‌خواهید این سرور را حذف کنید؟',
    },
    'Delete': {'fa': 'حذف'},
    'Cancel': {'fa': 'لغو'},

    'VPN Permission Required': {'fa': 'مجوز VPN مورد نیاز است'},

    'Version': {'fa': 'نسخه'},
    'Developer': {'fa': 'توسعه‌دهنده'},
    'Support': {'fa': 'پشتیبانی'},

    // Time units
    'ms': {'fa': 'میلی‌ثانیه'},
    's': {'fa': 'ثانیه'},
    'm': {'fa': 'دقیقه'},
    'h': {'fa': 'ساعت'},

    // Buttons
    'Close': {'fa': 'بستن'},
    'Save': {'fa': 'ذخیره'},
    'OK': {'fa': 'تأیید'},
    'Yes': {'fa': 'بله'},
    'No': {'fa': 'خیر'},

    // Additional
    'Select Language / انتخاب زبان': {'fa': 'Select Language / انتخاب زبان'},
    'Language Changed': {'fa': 'زبان تغییر کرد'},
    'Close / بستن': {'fa': 'Close / بستن'},

    // Settings - General
    'Settings': {'fa': 'تنظیمات'},
    'Appearance': {'fa': 'ظاهر'},
    'General': {'fa': 'عمومی'},
    'Auto Connect': {'fa': 'اتصال خودکار'},
    'Automatically connect on app start': {
      'fa': 'اتصال خودکار هنگام شروع برنامه',
    },
    'Kill Switch': {'fa': 'قطع اینترنت'},
    'Block internet if VPN disconnects': {'fa': 'قطع اینترنت در صورت قطع VPN'},

    // Settings - Network (already defined above)
    'Per-App Proxy': {'fa': 'پروکسی هر برنامه'},
    'Choose which apps use VPN': {
      'fa': 'انتخاب برنامه‌هایی که از VPN استفاده می‌کنند',
    },

    // Settings - Data (already defined above)
    'Clear Server Cache': {'fa': 'پاک کردن کش سرور'},
    'Clear all cached server data': {'fa': 'پاک کردن تمام داده‌های کش شده'},
    'Clear All Data': {'fa': 'پاک کردن تمام داده‌ها'},
    'Reset all settings and servers': {'fa': 'بازنشانی تمام تنظیمات و سرورها'},

    // Settings - About
    'GitHub Repository': {'fa': 'مخزن GitHub'},
    'View source code and contribute': {'fa': 'مشاهده کد منبع و مشارکت'},
    'Report Issue': {'fa': 'گزارش مشکل'},
    'Report bugs or request features': {'fa': 'گزارش باگ یا درخواست ویژگی'},
    'Share App': {'fa': 'اشتراک‌گذاری برنامه'},
    'Share with friends': {'fa': 'اشتراک‌گذاری با دوستان'},
    'Open GitHub Releases': {'fa': 'باز کردن انتشارهای گیت‌هاب'},
    'Checking for updates': {'fa': 'در حال بررسی بروزرسانی'},
    'Update available': {'fa': 'بروزرسانی جدید موجود است'},
    'Update not available': {'fa': 'بروزرسانی جدیدی موجود نیست'},
    'Update failed': {'fa': 'بررسی بروزرسانی ناموفق بود'},

    // Servers Screen - Additional
    'Testing': {'fa': 'در حال تست'},
    'Testing servers...': {'fa': 'در حال تست سرورها...'},
    'Sort by Ping': {'fa': 'مرتب‌سازی بر اساس پینگ'},
    'Favorite': {'fa': 'علاقه‌مندی'},
    'Add to favorites': {'fa': 'افزودن به علاقه‌مندی‌ها'},
    'Remove from favorites': {'fa': 'حذف از علاقه‌مندی‌ها'},
    'Copy Config': {'fa': 'کپی پیکربندی'},
    'Edit Server': {'fa': 'ویرایش سرور'},
    'Share Config': {'fa': 'اشتراک‌گذاری پیکربندی'},

    // Connection Status
    'Connecting': {'fa': 'در حال اتصال'},
    'Connection Successful': {'fa': 'اتصال موفق'},
    'Connection Failed': {'fa': 'اتصال ناموفق'},
    'Disconnecting': {'fa': 'در حال قطع'},
    'Reconnecting': {'fa': 'در حال اتصال مجدد'},

    // Time
    'Just now': {'fa': 'همین الان'},
    'second': {'fa': 'ثانیه'},
    'minute': {'fa': 'دقیقه'},
    'hour': {'fa': 'ساعت'},
    'day': {'fa': 'روز'},
    'ago': {'fa': 'پیش'},

    // Common Actions
    'Add': {'fa': 'افزودن'},
    'Edit': {'fa': 'ویرایش'},
    'Remove': {'fa': 'حذف'},
    'Copy': {'fa': 'کپی'},
    'Paste': {'fa': 'چسباندن'},
    'Search': {'fa': 'جستجو'},
    'Filter': {'fa': 'فیلتر'},
    'Sort': {'fa': 'مرتب‌سازی'},
    'Clear': {'fa': 'پاک کردن'},
    'Reset': {'fa': 'بازنشانی'},
    'Apply': {'fa': 'اعمال'},
    'Done': {'fa': 'انجام شد'},
    'Run': {'fa': 'اجرا'},
    'Loading': {'fa': 'در حال بارگذاری'},
    'Please wait': {'fa': 'لطفاً صبر کنید'},

    // Errors
    'Error occurred': {'fa': 'خطایی رخ داد'},
    'Try again': {'fa': 'دوباره تلاش کنید'},
    'Something went wrong': {'fa': 'مشکلی پیش آمد'},
    'Check your connection': {'fa': 'اتصال خود را بررسی کنید'},
    'Permission denied': {'fa': 'مجوز رد شد'},
    'File not found': {'fa': 'فایل یافت نشد'},
    'Invalid config': {'fa': 'پیکربندی نامعتبر'},

    // Confirmation
    'Are you sure?': {'fa': 'آیا مطمئن هستید؟'},
    'This action cannot be undone': {'fa': 'این عمل قابل بازگشت نیست'},
    'Confirm': {'fa': 'تأیید'},
    'Continue': {'fa': 'ادامه'},
    'Back': {'fa': 'بازگشت'},
  };

  /// Get translation for a key
  static String tr(BuildContext context, String key) {
    try {
      final localizationService = Provider.of<LocalizationService>(
        context,
        listen: false,
      );

      if (localizationService.currentLocale.languageCode == 'fa') {
        return _translations[key]?['fa'] ?? key;
      }

      return key; // Return English (original key)
    } catch (e) {
      return key; // Fallback to original key
    }
  }

  /// Check if translation exists
  static bool hasTranslation(String key) {
    return _translations.containsKey(key);
  }

  /// Get all keys
  static List<String> get allKeys => _translations.keys.toList();
}

/// Extension for easy translation
extension TranslationExtension on String {
  String tr(BuildContext context) {
    return Translations.tr(context, this);
  }
}
