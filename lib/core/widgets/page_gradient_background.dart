import 'package:flutter/material.dart';

/// A reusable gradient background widget for pages
/// Used in HomePage, WalletPage, and similar pages
class PageGradientBackground extends StatelessWidget {
  /// Optional child widget to render on top of background
  final Widget? child;

  const PageGradientBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);

    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [
                  Color(0xFF0D1117),
                  Color(0xFF161B22),
                  Color(0xFF0D1117),
                ]
              : const [
                  Color(0xFFF8FAFC),
                  Color(0xFFFFFFFF),
                  Color(0xFFF1F5F9),
                ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Primary gradient blob - top right
          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.2,
            child: _GradientBlob(
              size: size.width * 0.7,
              color: theme.colorScheme.primary,
              opacity: isDark ? 0.12 : 0.08,
            ),
          ),
          // Secondary gradient blob - left side
          Positioned(
            bottom: size.height * 0.2,
            left: -size.width * 0.3,
            child: _GradientBlob(
              size: size.width * 0.6,
              color: theme.colorScheme.secondary,
              opacity: isDark ? 0.1 : 0.06,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _GradientBlob extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _GradientBlob({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
