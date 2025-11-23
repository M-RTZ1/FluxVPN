import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Wallpaper model
class Wallpaper {
  final String id;
  final String name;
  final String path; // Local file path or URL
  final String category;
  final int size; // File size in bytes
  final bool isFavorite;
  final int timestamp;

  Wallpaper({
    required this.id,
    required this.name,
    required this.path,
    required this.category,
    required this.size,
    this.isFavorite = false,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'path': path,
    'category': category,
    'size': size,
    'isFavorite': isFavorite,
    'timestamp': timestamp,
  };

  factory Wallpaper.fromJson(Map<String, dynamic> json) => Wallpaper(
    id: json['id'],
    name: json['name'],
    path: json['path'],
    category: json['category'],
    size: json['size'],
    isFavorite: json['isFavorite'] ?? false,
    timestamp: json['timestamp'],
  );
}

/// Wallpaper Service for managing wallpapers
class WallpaperService extends ChangeNotifier {
  static const String _wallpaperKey = 'current_wallpaper';
  static const String _favoritesKey = 'favorite_wallpapers';
  static const String _wallpapersKey = 'wallpapers_list';

  Wallpaper? _currentWallpaper;
  List<Wallpaper> _wallpapers = [];
  List<String> _favorites = [];
  bool _isLoading = false;

  Wallpaper? get currentWallpaper => _currentWallpaper;
  List<Wallpaper> get wallpapers => _wallpapers;
  List<String> get favorites => _favorites;
  bool get isLoading => _isLoading;

  WallpaperService() {
    _initialize();
  }

  /// Initialize wallpaper service
  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load current wallpaper
      final wallpaperJson = prefs.getString(_wallpaperKey);
      if (wallpaperJson != null) {
        _currentWallpaper = Wallpaper.fromJson(
          Map<String, dynamic>.from(Map.from(jsonDecode(wallpaperJson) as Map)),
        );
      }

      // Load favorites
      _favorites = prefs.getStringList(_favoritesKey) ?? [];

      // Load wallpapers list
      final wallpapersJson = prefs.getStringList(_wallpapersKey) ?? [];
      if (wallpapersJson.isEmpty) {
        // Initialize with default wallpapers
        _wallpapers = _getDefaultWallpapers();
        await _persistWallpapers(prefs);
      } else {
        _wallpapers = wallpapersJson
            .map(
              (json) => Wallpaper.fromJson(
                Map<String, dynamic>.from(Map.from(jsonDecode(json) as Map)),
              ),
            )
            .toList();

        await _ensureDefaultWallpapersPresent(prefs);
      }
    } catch (e) {
      debugPrint('Error initializing wallpaper service: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get default wallpapers from assets
  List<Wallpaper> _getDefaultWallpapers() {
    return [
      Wallpaper(
        id: 'wal_1',
        name: 'Cyberpunk City',
        path: 'assets/WAL1.png',
        category: 'Cyberpunk',
        size: 0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
      Wallpaper(
        id: 'wal_2',
        name: 'Snow Mountain',
        path: 'assets/WAL2.png',
        category: 'Nature',
        size: 0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
      Wallpaper(
        id: 'wal_3',
        name: 'Anime Sunset',
        path: 'assets/WAL3.png',
        category: 'Anime',
        size: 0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    ];
  }

  /// Ensure default asset wallpapers exist even if user already has data
  Future<void> _ensureDefaultWallpapersPresent(SharedPreferences prefs) async {
    final defaultWallpapers = _getDefaultWallpapers();
    var updated = false;

    for (final defaultWallpaper in defaultWallpapers) {
      final exists = _wallpapers.any((w) => w.id == defaultWallpaper.id);
      if (!exists) {
        // Insert at beginning so assets appear first
        _wallpapers.insert(0, defaultWallpaper);
        updated = true;
      }
    }

    if (updated) {
      await _persistWallpapers(prefs);
    }
  }

  Future<void> _persistWallpapers(SharedPreferences prefs) async {
    await prefs.setStringList(
      _wallpapersKey,
      _wallpapers.map((w) => jsonEncode(w.toJson())).toList(),
    );
  }

  /// Add wallpaper from gallery
  Future<Wallpaper?> addWallpaperFromGallery() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );

      if (image == null) return null;

      final wallpapersDir = await getWallpapersDirectory();
      final extension = image.path.split('.').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'wallpaper_$timestamp.$extension';
      final destination = File('${wallpapersDir.path}/$fileName');

      await destination.writeAsBytes(await image.readAsBytes());
      final fileSize = await destination.length();

      final newWallpaper = Wallpaper(
        id: 'user_$timestamp',
        name: 'Gallery Image',
        path: destination.path,
        category: 'Custom',
        size: fileSize,
        timestamp: timestamp,
      );

      _wallpapers.insert(0, newWallpaper);

      final prefs = await SharedPreferences.getInstance();
      await _persistWallpapers(prefs);

      notifyListeners();
      return newWallpaper;
    } catch (e) {
      debugPrint('Error adding wallpaper from gallery: $e');
      rethrow;
    }
  }

  /// Set current wallpaper
  Future<void> setCurrentWallpaper(Wallpaper wallpaper) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_wallpaperKey, jsonEncode(wallpaper.toJson()));

      _currentWallpaper = wallpaper;
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting wallpaper: $e');
      rethrow;
    }
  }

  /// Remove current wallpaper
  Future<void> removeCurrentWallpaper() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_wallpaperKey);

      _currentWallpaper = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing wallpaper: $e');
      rethrow;
    }
  }

  /// Add wallpaper to favorites
  Future<void> addToFavorites(String wallpaperId) async {
    try {
      if (!_favorites.contains(wallpaperId)) {
        _favorites.add(wallpaperId);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_favoritesKey, _favorites);

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding to favorites: $e');
      rethrow;
    }
  }

  /// Remove wallpaper from favorites
  Future<void> removeFromFavorites(String wallpaperId) async {
    try {
      _favorites.remove(wallpaperId);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, _favorites);

      notifyListeners();
    } catch (e) {
      debugPrint('Error removing from favorites: $e');
      rethrow;
    }
  }

  /// Get favorite wallpapers
  List<Wallpaper> getFavoriteWallpapers() {
    return _wallpapers.where((w) => _favorites.contains(w.id)).toList();
  }

  /// Get wallpapers by category
  List<Wallpaper> getWallpapersByCategory(String category) {
    return _wallpapers.where((w) => w.category == category).toList();
  }

  /// Add wallpaper to list
  Future<void> addWallpaper(Wallpaper wallpaper) async {
    try {
      _wallpapers.add(wallpaper);

      final prefs = await SharedPreferences.getInstance();
      final wallpapersJson = _wallpapers
          .map((w) => jsonEncode(w.toJson()))
          .toList();
      await prefs.setStringList(_wallpapersKey, wallpapersJson);

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding wallpaper: $e');
      rethrow;
    }
  }

  /// Delete wallpaper
  Future<void> deleteWallpaper(String wallpaperId) async {
    try {
      _wallpapers.removeWhere((w) => w.id == wallpaperId);
      _favorites.remove(wallpaperId);

      final prefs = await SharedPreferences.getInstance();
      final wallpapersJson = _wallpapers
          .map((w) => jsonEncode(w.toJson()))
          .toList();
      await prefs.setStringList(_wallpapersKey, wallpapersJson);
      await prefs.setStringList(_favoritesKey, _favorites);

      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting wallpaper: $e');
      rethrow;
    }
  }

  /// Get wallpaper file size
  Future<int> getWallpaperFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      debugPrint('Error getting file size: $e');
      return 0;
    }
  }

  /// Get wallpapers directory
  Future<Directory> getWallpapersDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final wallpaperDir = Directory('${appDir.path}/wallpapers');

    if (!await wallpaperDir.exists()) {
      await wallpaperDir.create(recursive: true);
    }

    return wallpaperDir;
  }

  /// Clear all wallpapers
  Future<void> clearAllWallpapers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_wallpaperKey);
      await prefs.remove(_favoritesKey);
      await prefs.remove(_wallpapersKey);

      _currentWallpaper = null;
      _wallpapers.clear();
      _favorites.clear();

      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing wallpapers: $e');
      rethrow;
    }
  }
}

// Helper function for JSON encoding
String jsonEncode(dynamic object) {
  if (object is Map) {
    return object.toString();
  }
  return object.toString();
}

// Helper function for JSON decoding
dynamic jsonDecode(String json) {
  // Simple JSON parsing - in production use dart:convert
  return json;
}
