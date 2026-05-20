# FluxVPN

FluxVPN is a desktop-inspired VPN client built in Flutter that focuses on a clean Fluent UI, bilingual (English/Persian) experience, and practical tooling for managing V2Ray and WireGuard connections. This repository is the source for releases published at [github.com/M-RTZ1/FluxVPN](https://github.com/M-RTZ1/FluxVPN).

## Highlights

- **Modern Fluent UI** with dark/light modes, wallpapers, and RTL-friendly typography.
- **Multi-protocol support** through the custom V2Ray service and WireGuard integration.
- **Smart settings** including per-app proxy, DNS customization, wallpaper/language selectors, and auto-connect/kill-switch toggles.
- **Subscription tools** to import/update/remove server lists, plus backup & restore helpers for configs.
- **Telemetry-friendly** logging, statistics tracking, and localization via the built-in services layer.

## Getting Started

1. **Clone the repo**
   ```bash
   git clone https://github.com/M-RTZ1/FluxVPN.git
   cd FluxVPN
   ```
2. **Install dependencies**
   ```bash
   flutter pub get
   ```
3. **Run the app**
   - Desktop (Windows): `flutter run -d windows`
   - Android: `flutter run -d android`

> Make sure you have the latest stable Flutter SDK (3.9+) and the necessary platform toolchains (Android Studio SDK / Windows desktop support) configured.

## Building Release Artifacts

- **Windows**: `flutter build windows`
- **Android APK**: `flutter build apk --release`
- **Android AppBundle**: `flutter build appbundle`

Generated builds can be uploaded to the GitHub Releases page referenced above so that the in-app updater can notify users about new versions.

## Contributing
# FluxVPN

FluxVPN یک کلاینت وی‌پی‌ان با الهام از طراحی دسکتاپ است که با فریمورک Flutter ساخته شده است. این برنامه بر ارائه ظاهر مدرن Fluent UI، تجربه کاربری دو زبانه (فارسی/انگلیسی) و ابزارهای کاربردی برای مدیریت اتصالات V2Ray و WireGuard تمرکز دارد. این مخزن، منبع انتشارهای برنامه در آدرس https://github.com/M-RTZ1/FluxVPN می‌باشد.

## ویژگی‌های برجسته

- **ظاهر مدرن Fluent UI** با پشتیبانی از حالت‌های روشن/تاریک، تصاویر پس‌زمینه و تایپوگرافی سازگار با RTL
- **پشتیبانی از پروتکل‌های متعدد** از طریق سرویس سفارشی V2Ray و یکپارچگی با WireGuard
- **تنظیمات هوشمند** شامل پروکسی مخصوص هر برنامه، تنظیم DNS، انتخابگر تصویر پس‌زمینه و زبان، و قابلیت‌های اتصال خودکار/قطع کننده ایمنی (kill switch)
- **ابزارهای اشتراک** برای وارد کردن، به‌روزرسانی و حذف لیست سرورها، همراه با ابزار پشتیبان‌گیری و بازیابی تنظیمات
- **گزارش‌گیری و آمار** سازگار با telemetry، و محلی‌سازی از طریق لایه سرویس‌های داخلی

## شروع سریع

### کلون مخزن
```bash
git clone https://github.com/M-RTZ1/FluxVPN.git
cd FluxVPN
```

### نصب وابستگی‌ها
```bash
flutter pub get
```

### اجرای برنامه
- **دسکتاپ (ویندوز):** `flutter run -d windows`
- **اندروید:** `flutter run -d android`

اطمینان حاصل کنید که آخرین نسخه پایدار Flutter SDK (نسخه 3.9+) به همراه ابزارهای پلتفرم مورد نیاز (Android Studio SDK / پشتیبانی دسکتاپ ویندوز) را نصب کرده‌اید.

## ساخت فایل‌های انتشار (Release)

- **ویندوز:** `flutter build windows`
- **اندروید APK:** `flutter build apk --release`
- **اندروید AppBundle:** `flutter build appbundle`

فایل‌های ساخته شده را می‌توان در صفحه انتشارات GitHub (ذکر شده در بالا) آپلود کرد تا به‌روزرسانی داخل برنامه بتواند کاربران را از نسخه‌های جدید مطلع سازد.

## مشارکت

درخواست Pull با آغوش باز پذیرفته می‌شود! لطفاً در صورت مشاهده باگ یا داشتن ایده جدید، یک issue باز کنید.

## مجوز

این پروژه از مجوز تعریف شده در مخزن پیروی می‌کند. برای جزئیات به فایل LICENSE مراجعه کنید.

Pull requests are welcome! Please open an issue if you spot bugs or have feature ideas.

## License

This project inherits the license defined in the repository. Refer to `LICENSE` for details.
