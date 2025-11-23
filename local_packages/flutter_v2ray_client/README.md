# Flutter V2Ray Client

## Customized Library for ProxyCloud

This is a customized version of the flutter_v2ray_client library specifically tailored for ProxyCloud applications.
It provides enhanced V2Ray/Xray proxy capabilities for Android with optimizations for ProxyCloud's architecture.

### ✨ Key Features

- **ProxyCloud Optimized**: Customized for ProxyCloud's specific requirements
- **Multi-Protocol Support**: VMess, VLess, Trojan, Shadowsocks, SOCKS
- **Advanced Transport**: XHTTP and HTTPUpgrade protocols
- **Dual Operation Modes**: VPN mode and proxy-only mode
- **Real-time Monitoring**: Live connection status and traffic statistics
- **Smart Configuration**: Parse and modify V2Ray share links
- **Network Control**: App exclusion and subnet bypass capabilities
- **Performance Focused**: Android-optimized with 16KB page size support

### 📱 Platform Support

| Platform | Status | Core Version |
|----------|--------|--------------|
| Android  | ✅ Done | Xray 25.9.11 |
| iOS      | ⏳ Coming Soon | - |
| Desktop  | ⏳ Coming Soon | - |

### 🛠 Installation

This library is specifically customized for ProxyCloud and integrated as a local package.

### 📚 Core Capabilities

#### V2ray Class
- `initialize()` - Initialize the V2Ray client
- `requestPermission()` - Request necessary Android permissions
- `startV2Ray()` - Start V2Ray connection with custom config
- `stopV2Ray()` - Stop V2Ray connection
- `getServerDelay()` - Test server connectivity
- `getCoreVersion()` - Get Xray core version
- `parseFromURL()` - Parse V2Ray share links

#### V2RayURL Class
- `remark` - Server name/comment
- `inbound` - Inbound configuration
- `log` - Log settings
- `dns` - DNS configuration
- `getFullConfiguration()` - Generate complete JSON config

### 🤝 Customization for ProxyCloud

This library has been specifically enhanced and customized for ProxyCloud with:
- Optimized configuration handling for ProxyCloud's architecture
- Enhanced compatibility with ProxyCloud's UI components
- Streamlined API for ProxyCloud's service integration
- Performance improvements tailored for ProxyCloud's usage patterns

### 📋 Attribution

Based on the original flutter_v2ray_client library with custom modifications for ProxyCloud.