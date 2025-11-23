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

Pull requests are welcome! Please open an issue if you spot bugs or have feature ideas.

## License

This project inherits the license defined in the repository. Refer to `LICENSE` for details.
