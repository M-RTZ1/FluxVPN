import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluxvpn/services/wallpaper_service.dart';
import 'package:fluxvpn/theme/app_theme.dart';
import 'package:fluxvpn/l10n/app_localizations.dart';

class WallpaperSettingsScreen extends StatefulWidget {
  const WallpaperSettingsScreen({super.key});

  @override
  State<WallpaperSettingsScreen> createState() =>
      _WallpaperSettingsScreenState();
}

class _WallpaperSettingsScreenState extends State<WallpaperSettingsScreen> {
  /// Build wallpaper image from asset or file path
  Widget _buildWallpaperImage(String path) {
    try {
      // Check if path is an asset
      if (path.startsWith('assets/')) {
        return Image.asset(
          path,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppTheme.md3DarkSurface,
              child: const Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                  size: 40,
                ),
              ),
            );
          },
        );
      } else {
        // File path
        return Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppTheme.md3DarkSurface,
              child: const Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                  size: 40,
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      return Container(
        color: AppTheme.md3DarkSurface,
        child: const Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.md3DarkBackground,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.wallpaperSettings ??
              'Wallpaper Settings',
        ),
        backgroundColor: AppTheme.md3DarkBackground,
        elevation: 0,
      ),
      body: Builder(
        builder: (context) {
          final wallpaperService = Provider.of<WallpaperService>(context);
          final wallpapers = wallpaperService.wallpapers;
          final currentWallpaper = wallpaperService.currentWallpaper;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Current Wallpaper Section
              if (currentWallpaper != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.defaultWallpaper ??
                          'Current Wallpaper',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.connectedGreen.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _buildWallpaperImage(currentWallpaper.path),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentWallpaper.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                currentWallpaper.category,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await wallpaperService.removeCurrentWallpaper();
                          },
                          icon: const Icon(Icons.delete),
                          label: Text(
                            AppLocalizations.of(context)?.wallpaperDelete ??
                                'Delete',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.disconnectedRed,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),

              // Import from gallery button
              ElevatedButton.icon(
                onPressed: () async {
                  final newWallpaper = await wallpaperService
                      .addWallpaperFromGallery();

                  if (newWallpaper != null && mounted) {
                    await wallpaperService.setCurrentWallpaper(newWallpaper);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)?.wallpaperAdded ??
                                'Wallpaper imported from gallery',
                          ),
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.photo_library),
                label: Text(
                  AppLocalizations.of(context)?.wallpaperImportFromGallery ??
                      'Add from Gallery',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.connectedGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Available Wallpapers
              Text(
                AppLocalizations.of(context)?.selectWallpaper ??
                    'Select Wallpaper',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Wallpaper Grid
              if (wallpapers.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      AppLocalizations.of(context)?.noWallpapers ??
                          'No wallpapers available',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: wallpapers.length,
                  itemBuilder: (context, index) {
                    final wallpaper = wallpapers[index];
                    final isFavorite = wallpaperService.favorites.contains(
                      wallpaper.id,
                    );
                    final isSelected = currentWallpaper?.id == wallpaper.id;

                    return GestureDetector(
                      onTap: () async {
                        await wallpaperService.setCurrentWallpaper(wallpaper);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.connectedGreen
                                : Colors.grey.withValues(alpha: 0.3),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Wallpaper Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: _buildWallpaperImage(wallpaper.path),
                            ),

                            // Overlay
                            if (isSelected)
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(11),
                                  color: AppTheme.connectedGreen.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),

                            // Info
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(11),
                                    bottomRight: Radius.circular(11),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.7),
                                    ],
                                  ),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      wallpaper.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      wallpaper.category,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Favorite Button
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () async {
                                  if (isFavorite) {
                                    await wallpaperService.removeFromFavorites(
                                      wallpaper.id,
                                    );
                                  } else {
                                    await wallpaperService.addToFavorites(
                                      wallpaper.id,
                                    );
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite
                                        ? Colors.red
                                        : Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),

                            // Selected Indicator
                            if (isSelected)
                              Positioned(
                                top: 4,
                                left: 4,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.connectedGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.black,
                                    size: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
