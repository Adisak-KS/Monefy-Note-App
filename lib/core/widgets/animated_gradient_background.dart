import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated gradient background with floating blobs
class AnimatedGradientBackground extends StatefulWidget {
  final Widget? child;
  final List<Color>? colors;
  final Duration animationDuration;
  final bool showFloatingBlobs;
  final int blobCount;

  const AnimatedGradientBackground({
    super.key,
    this.child,
    this.colors,
    this.animationDuration = const Duration(seconds: 8),
    this.showFloatingBlobs = true,
    this.blobCount = 3,
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _blobController;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();

    _gradientController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat(reverse: true);

    _blobController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _gradientController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _blobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);

    final defaultColors = isDark
        ? [
            const Color(0xFF0D1117),
            const Color(0xFF161B22),
            const Color(0xFF0D1117),
          ]
        : [
            const Color(0xFFF8FAFC),
            const Color(0xFFFFFFFF),
            const Color(0xFFF1F5F9),
          ];

    final colors = widget.colors ?? defaultColors;

    return AnimatedBuilder(
      animation: _gradientAnimation,
      builder: (context, child) {
        // Animate gradient angle
        final angle = _gradientAnimation.value * math.pi / 4;

        return Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(
                math.cos(angle) * -1,
                math.sin(angle) * -1,
              ),
              end: Alignment(
                math.cos(angle),
                math.sin(angle),
              ),
              colors: colors,
            ),
          ),
          child: Stack(
            children: [
              // Animated floating blobs
              if (widget.showFloatingBlobs && !isDark)
                ..._buildFloatingBlobs(context, size),
              // Primary color blob - top right
              _buildPrimaryBlob(context, size),
              // Secondary color blob - left
              _buildSecondaryBlob(context, size),
              // Child content
              if (widget.child != null) widget.child!,
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildFloatingBlobs(BuildContext context, Size size) {
    final theme = Theme.of(context);
    final blobs = <Widget>[];

    for (int i = 0; i < widget.blobCount; i++) {
      blobs.add(
        AnimatedBuilder(
          animation: _blobController,
          builder: (context, child) {
            final progress = (_blobController.value + (i / widget.blobCount)) % 1.0;
            final x = size.width * (0.2 + 0.6 * math.sin(progress * math.pi * 2));
            final y = size.height * (0.1 + 0.3 * math.cos(progress * math.pi * 2 + i));
            final opacity = 0.03 + 0.02 * math.sin(progress * math.pi * 4);

            return Positioned(
              left: x - 100,
              top: y - 100,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: opacity),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return blobs;
  }

  Widget _buildPrimaryBlob(BuildContext context, Size size) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _gradientAnimation,
      builder: (context, child) {
        final offset = 20 * math.sin(_gradientAnimation.value * math.pi * 2);

        return Positioned(
          top: -size.height * 0.15 + offset,
          right: -size.width * 0.3,
          child: Container(
            width: size.width * 0.8,
            height: size.width * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [
                        theme.colorScheme.primary.withValues(alpha: 0.15),
                        theme.colorScheme.primary.withValues(alpha: 0.05),
                        Colors.transparent,
                      ]
                    : [
                        theme.colorScheme.primary.withValues(alpha: 0.15),
                        theme.colorScheme.primary.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecondaryBlob(BuildContext context, Size size) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _gradientAnimation,
      builder: (context, child) {
        final offset = 15 * math.cos(_gradientAnimation.value * math.pi * 2);

        return Positioned(
          top: size.height * 0.25 + offset,
          left: -size.width * 0.4,
          child: Container(
            width: size.width * 0.7,
            height: size.width * 0.7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [
                        theme.colorScheme.secondary.withValues(alpha: 0.12),
                        theme.colorScheme.secondary.withValues(alpha: 0.04),
                        Colors.transparent,
                      ]
                    : [
                        theme.colorScheme.secondary.withValues(alpha: 0.12),
                        theme.colorScheme.secondary.withValues(alpha: 0.04),
                        Colors.transparent,
                      ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A simpler animated gradient for headers/app bars
class AnimatedGradientHeader extends StatefulWidget {
  final Widget child;
  final double height;
  final List<Color>? colors;
  final Duration animationDuration;
  final BorderRadius? borderRadius;

  const AnimatedGradientHeader({
    super.key,
    required this.child,
    this.height = 200,
    this.colors,
    this.animationDuration = const Duration(seconds: 6),
    this.borderRadius,
  });

  @override
  State<AnimatedGradientHeader> createState() => _AnimatedGradientHeaderState();
}

class _AnimatedGradientHeaderState extends State<AnimatedGradientHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final colors = widget.colors ??
        [
          primary,
          primary.withValues(alpha: 0.8),
          Color.lerp(primary, theme.colorScheme.secondary, 0.3)!,
        ];

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final t = _animation.value;

        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(-1 + t, -1 + t * 0.5),
              end: Alignment(1 - t * 0.5, 1 - t),
              colors: colors,
              stops: [
                0.0,
                0.5 + (t * 0.1),
                1.0,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}
