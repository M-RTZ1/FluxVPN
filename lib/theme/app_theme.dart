import 'package:fluent_ui/fluent_ui.dart';
import 'dart:ui';

class AppTheme {
  // 🎨 MATERIAL DESIGN 3 - DARK THEME
  static FluentThemeData darkTheme({String? fontFamily}) {
    return FluentThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: md3DarkBackground,
      navigationPaneTheme: NavigationPaneThemeData(
        backgroundColor: md3DarkSurface,
        highlightColor: md3Primary.withOpacity(0.12),
        selectedIconColor: ButtonState.all(md3Primary),
        unselectedIconColor: ButtonState.all(md3OnSurfaceVariant),
      ),
      iconTheme: IconThemeData(color: md3OnSurface),
      typography: Typography.raw(
        caption: TextStyle(fontFamily: fontFamily),
        body: TextStyle(fontFamily: fontFamily),
        bodyLarge: TextStyle(fontFamily: fontFamily),
        bodyStrong: TextStyle(fontFamily: fontFamily),
        subtitle: TextStyle(fontFamily: fontFamily),
        title: TextStyle(fontFamily: fontFamily),
        titleLarge: TextStyle(fontFamily: fontFamily),
        display: TextStyle(fontFamily: fontFamily),
      ),
    );
  }

  // 🎨 MATERIAL DESIGN 3 - LIGHT THEME
  static FluentThemeData lightTheme({String? fontFamily}) {
    return FluentThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: md3LightBackground,
      navigationPaneTheme: NavigationPaneThemeData(
        backgroundColor: md3LightSurface,
        highlightColor: md3Primary.withOpacity(0.08),
        selectedIconColor: ButtonState.all(md3Primary),
        unselectedIconColor: ButtonState.all(md3OnSurfaceVariant),
      ),
      cardColor: md3LightSurface,
      iconTheme: IconThemeData(color: md3OnSurface),
      typography: Typography.raw(
        caption: TextStyle(fontFamily: fontFamily),
        body: TextStyle(fontFamily: fontFamily),
        bodyLarge: TextStyle(fontFamily: fontFamily),
        bodyStrong: TextStyle(fontFamily: fontFamily),
        subtitle: TextStyle(fontFamily: fontFamily),
        title: TextStyle(fontFamily: fontFamily),
        titleLarge: TextStyle(fontFamily: fontFamily),
        display: TextStyle(fontFamily: fontFamily),
      ),
    );
  }
  
  // 🎨 MATERIAL DESIGN 3 COLOR SYSTEM
  // Primary Colors
  static const Color md3Primary = Color(0xFF6750A4);           // Purple
  static const Color md3OnPrimary = Color(0xFFFFFFFF);         // White
  static const Color md3PrimaryContainer = Color(0xFFEADDFF);  // Light Purple
  static const Color md3OnPrimaryContainer = Color(0xFF21005D);
  
  // Secondary Colors
  static const Color md3Secondary = Color(0xFF625B71);
  static const Color md3OnSecondary = Color(0xFFFFFFFF);
  static const Color md3SecondaryContainer = Color(0xFFE8DEF8);
  
  // Tertiary Colors
  static const Color md3Tertiary = Color(0xFF7D5260);
  static const Color md3OnTertiary = Color(0xFFFFFFFF);
  
  // Surface Colors - Dark
  static const Color md3DarkBackground = Color(0xFF1C1B1F);
  static const Color md3DarkSurface = Color(0xFF1C1B1F);
  static const Color md3DarkSurfaceVariant = Color(0xFF49454F);
  static const Color md3OnSurface = Color(0xFFE6E1E5);
  static const Color md3OnSurfaceVariant = Color(0xFFCAC4D0);
  
  // Surface Colors - Light
  static const Color md3LightBackground = Color(0xFFFEF7FF);
  static const Color md3LightSurface = Color(0xFFFEF7FF);
  static const Color md3LightSurfaceVariant = Color(0xFFE7E0EC);
  
  // Status Colors
  static const Color md3Error = Color(0xFFB3261E);
  static const Color md3Success = Color(0xFF00C853);
  
  // Legacy gradient constants for compatibility
  static const Color primaryGradientStart = md3Primary;
  static const Color primaryGradientEnd = md3Tertiary;

  // Legacy neon colors (keeping for compatibility)
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color neonPurple = md3Primary;
  static const Color neonPink = md3Tertiary;
  static const Color neonGreen = md3Success;
  static const Color neonBlue = Color(0xFF0080FF);
  static const Color neonOrange = Color(0xFFFF6B00);
  
  // Legacy background colors
  static const Color darkBg = md3DarkBackground;
  static const Color darkCard = md3DarkSurface;
  static const Color darkCardAlt = md3DarkSurfaceVariant;
  static const Color darkSurface = md3DarkSurface;
  
  // Legacy support with neon colors
  static const Color primaryViolet = neonPurple;
  static const Color primaryIndigo = neonBlue;
  static const Color accentRose = neonPink;
  static const Color accentEmerald = neonGreen;
  static const Color accentAmber = neonOrange;
  static const Color accentSky = neonCyan;
  
  static const Color lightBg = Color(0xFFF0F4F8);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF8FAFC);
  
  // Glass Effect Colors
  static const Color glassLight = Color(0x15FFFFFF);
  static const Color glassMedium = Color(0x25FFFFFF);
  static const Color glassBorder = Color(0x30FFFFFF);
  
  // Status Colors
  static const Color connectedGreen = Color(0xFF10B981);
  static const Color disconnectedRed = Color(0xFFF43F5E);
  static const Color warningOrange = Color(0xFFFBBF24);
  static const Color infoBlue = Color(0xFF0EA5E9);
  
  // Legacy support
  static const Color primaryCyan = primaryViolet;
  static const Color primaryPurple = primaryIndigo;
  static const Color primaryBlue = accentSky;
  static const Color accentPink = accentRose;
  static const Color accentOrange = accentAmber;
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryCyan, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [primaryCyan, primaryBlue, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glassmorphism Effect
  static BoxDecoration glassDecoration({
    double borderRadius = 20,
    double opacity = 0.1,
    bool isDark = true,
  }) {
    if (isDark) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: glassLight,
        border: Border.all(
          color: glassBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      );
    } else {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: Colors.white.withOpacity(0.7),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryViolet.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      );
    }
  }
  
  // Neumorphic Card Effect
  static BoxDecoration neumorphicDecoration({
    double borderRadius = 24,
    bool isDark = true,
    bool isPressed = false,
  }) {
    if (isDark) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: darkCard,
        boxShadow: isPressed
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: darkSurface.withOpacity(0.8),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(-8, -8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(8, 8),
                ),
              ],
      );
    } else {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: lightBg,
        boxShadow: isPressed
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(-8, -8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(8, 8),
                ),
              ],
      );
    }
  }

  // Modern Minimal Card with Backdrop Blur Effect
  static BoxDecoration premiumCardDecoration({
    double borderRadius = 24,
    bool isDark = true,
  }) {
    if (isDark) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: [
            glassMedium,
            glassLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: glassBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryViolet.withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 0,
          ),
        ],
      );
    } else {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: Colors.white,
        border: Border.all(
          color: primaryViolet.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryViolet.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      );
    }
  }

  // 💫 NEON GLOW EFFECT - For glowing elements
  static BoxDecoration neonGlowDecoration({
    double borderRadius = 16,
    Color glowColor = neonCyan,
    double glowIntensity = 0.6,
    bool isActive = true,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        colors: [
          glowColor,
          glowColor.withOpacity(0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: isActive
          ? [
              // Outer glow
              BoxShadow(
                color: glowColor.withOpacity(glowIntensity),
                blurRadius: 30,
                spreadRadius: 5,
              ),
              // Inner glow
              BoxShadow(
                color: glowColor.withOpacity(glowIntensity * 0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
              // Sharp edge glow
              BoxShadow(
                color: glowColor,
                blurRadius: 5,
                spreadRadius: 0,
              ),
            ]
          : [],
    );
  }
  
  // 🎨 MATERIAL DESIGN 3 - ELEVATED CARD
  static BoxDecoration md3ElevatedCard({
    double borderRadius = 16,
    bool isDark = true,
    int elevation = 1,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: isDark ? md3DarkSurfaceVariant : md3LightSurface,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(elevation == 1 ? 0.05 : elevation == 2 ? 0.08 : 0.12),
          blurRadius: elevation == 1 ? 3 : elevation == 2 ? 6 : 12,
          spreadRadius: 0,
          offset: Offset(0, elevation == 1 ? 1 : elevation == 2 ? 2 : 4),
        ),
      ],
    );
  }
  
  // 🎨 MATERIAL DESIGN 3 - FILLED CARD
  static BoxDecoration md3FilledCard({
    double borderRadius = 16,
    bool isDark = true,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: isDark ? md3DarkSurfaceVariant : md3LightSurfaceVariant,
    );
  }
  
  // 🎨 MATERIAL DESIGN 3 - OUTLINED CARD
  static BoxDecoration md3OutlinedCard({
    double borderRadius = 16,
    bool isDark = true,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: isDark ? md3DarkSurface : md3LightSurface,
      border: Border.all(
        color: isDark ? md3OnSurfaceVariant.withOpacity(0.12) : md3OnSurfaceVariant.withOpacity(0.12),
        width: 1,
      ),
    );
  }

  // 🔮 CYBER CARD - Dark card with neon border (Legacy)
  static BoxDecoration cyberCardDecoration({
    double borderRadius = 20,
    Color borderColor = neonCyan,
    bool isDark = true,
  }) {
    return md3ElevatedCard(borderRadius: borderRadius, isDark: isDark, elevation: 2);
  }

  static BoxDecoration gradientButtonDecoration({
    double borderRadius = 12,
    bool isActive = false,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: isActive ? successGradient : primaryGradient,
      boxShadow: [
        BoxShadow(
          color: (isActive ? connectedGreen : primaryCyan).withOpacity(0.4),
          blurRadius: 16,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static Color getPingColor(int? ping) {
    if (ping == null || ping < 0) return Colors.grey;
    if (ping < 100) return connectedGreen;
    if (ping < 300) return warningOrange;
    return disconnectedRed;
  }

  static String formatSpeed(int bytesPerSecond) {
    if (bytesPerSecond < 1024) {
      return '$bytesPerSecond B/s';
    } else if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    } else {
      return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    }
  }

  static String formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}

