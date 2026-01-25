import 'dart:ui';
import 'package:flutter/material.dart';

/// A glassmorphism-style card with blur effect and subtle border
class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.borderRadius,
    this.padding,
    this.margin,
    this.borderColor,
    this.borderWidth = 1.0,
    this.boxShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(20);
    final effectiveBorderColor = borderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.8));

    final effectiveShadow = boxShadow ??
        [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          if (!isDark)
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.8),
              blurRadius: 0,
              offset: const Offset(0, -1),
              spreadRadius: 0,
            ),
        ];

    Widget card = ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: opacity * 0.5)
                : Colors.white.withValues(alpha: opacity * 5),
            borderRadius: effectiveBorderRadius,
            border: Border.all(
              color: effectiveBorderColor,
              width: borderWidth,
            ),
            boxShadow: effectiveShadow,
          ),
          padding: padding,
          child: child,
        ),
      ),
    );

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    if (onTap != null) {
      card = GestureDetector(onTap: onTap, child: card);
    }

    return card;
  }
}

/// A glassmorphism card with press animation effect
class AnimatedGlassCard extends StatefulWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Duration animationDuration;

  const AnimatedGlassCard({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.borderRadius,
    this.padding,
    this.margin,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  @override
  State<AnimatedGlassCard> createState() => _AnimatedGlassCardState();
}

class _AnimatedGlassCardState extends State<AnimatedGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _shadowAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveBorderRadius =
        widget.borderRadius ?? BorderRadius.circular(20);

    return GestureDetector(
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: widget.margin,
              decoration: BoxDecoration(
                borderRadius: effectiveBorderRadius,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black
                            .withValues(alpha: 0.3 * _shadowAnimation.value)
                        : Colors.black
                            .withValues(alpha: 0.08 * _shadowAnimation.value),
                    blurRadius: 20 * _shadowAnimation.value,
                    offset: Offset(0, 8 * _shadowAnimation.value),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: effectiveBorderRadius,
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: widget.blur,
                    sigmaY: widget.blur,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: widget.opacity * 0.5)
                          : Colors.white.withValues(alpha: widget.opacity * 5),
                      borderRadius: effectiveBorderRadius,
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    padding: widget.padding,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
