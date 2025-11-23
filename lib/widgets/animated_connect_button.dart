import 'package:flutter/material.dart';
import 'dart:ui';

class AnimatedConnectButton extends StatefulWidget {
  final bool isConnected;
  final bool isConnecting;
  final VoidCallback? onTap;

  const AnimatedConnectButton({
    super.key,
    required this.isConnected,
    required this.isConnecting,
    this.onTap,
  });

  @override
  State<AnimatedConnectButton> createState() => _AnimatedConnectButtonState();
}

class _AnimatedConnectButtonState extends State<AnimatedConnectButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.88).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _bounceController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _bounceController.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    _bounceController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.5),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isConnected
                            ? const Color(0xFF36FDDC).withOpacity(0.75)
                            : const Color(0xFF735CFF).withOpacity(0.75),
                        blurRadius: 50,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Center(
                    child: widget.isConnecting
                        ? const SizedBox(
                            width: 38,
                            height: 38,
                            child: CircularProgressIndicator(
                              strokeWidth: 5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Icon(
                            widget.isConnected
                                ? Icons.shield
                                : Icons.power_settings_new,
                            size: 50,
                            color: Colors.white,
                          ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Text(
          widget.isConnected ? 'CONNECTED' : 'TAP TO CONNECT',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: widget.isConnected
                ? const Color(0xFF36FDDC)
                : Colors.white.withOpacity(0.85),
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
