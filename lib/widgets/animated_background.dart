import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatefulWidget {
  final bool isConnected;
  final Widget child;
  final bool enableAnimation;
  final String? wallpaperPath;

  const AnimatedBackground({
    super.key,
    required this.isConnected,
    required this.child,
    this.enableAnimation = false, // ✅ پیش‌فرض خاموش برای performance
    this.wallpaperPath,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _updateAnimation();
  }

  void _updateAnimation() {
    // ✅ فقط وقتی enableAnimation = true اجرا کن
    if (widget.enableAnimation && !_isAnimating) {
      _controller.repeat();
      _isAnimating = true;
    } else if (!widget.enableAnimation && _isAnimating) {
      _controller.stop();
      _isAnimating = false;
    }
  }

  @override
  void didUpdateWidget(AnimatedBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enableAnimation != widget.enableAnimation) {
      _updateAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableAnimation) {
      return Container(
        decoration: _buildStaticDecoration(),
        constraints: const BoxConstraints.expand(),
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: _buildAnimatedDecoration(),
          constraints: const BoxConstraints.expand(),
          child: child,
        );
      },
      child: widget.child,
    );
  }

  BoxDecoration _buildStaticDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: widget.isConnected
            ? const [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)]
            : const [Color(0xFF1A1A2E), Color(0xFF2D1B4E), Color(0xFF3E2463)],
      ),
      image: _buildWallpaperImage(),
    );
  }

  BoxDecoration _buildAnimatedDecoration() {
    final value = _controller.value * 2 * math.pi;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment(math.cos(value) * 0.5, math.sin(value) * 0.5),
        end: Alignment(-math.cos(value) * 0.5, -math.sin(value) * 0.5),
        colors: widget.isConnected
            ? const [
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
                Color(0xFF0F3460),
                Color(0xFF16213E),
              ]
            : const [
                Color(0xFF1A1A2E),
                Color(0xFF2D1B4E),
                Color(0xFF3E2463),
                Color(0xFF2D1B4E),
              ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ),
      image: _buildWallpaperImage(),
    );
  }

  /// Build background wallpaper image (asset or file) if a path is provided
  DecorationImage? _buildWallpaperImage() {
    final path = widget.wallpaperPath;
    if (path == null || path.isEmpty) return null;

    try {
      ImageProvider imageProvider;
      if (path.startsWith('assets/')) {
        imageProvider = AssetImage(path);
      } else {
        imageProvider = FileImage(File(path));
      }

      return DecorationImage(image: imageProvider, fit: BoxFit.cover);
    } catch (_) {
      // اگر لود تصویر به هر دلیل شکست بخورد، فقط گرادیانت نمایش داده می‌شود
      return null;
    }
  }
}
