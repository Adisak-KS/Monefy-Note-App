import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieIcon extends StatelessWidget {
  final String? assetPath;
  final String? networkUrl;
  final IconData fallbackIcon;
  final double size;

  const LottieIcon({
    super.key,
    this.assetPath,
    this.networkUrl,
    required this.fallbackIcon,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.15),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: Center(
          child: _buildLottie(),
        ),
      ),
    );
  }

  Widget _buildLottie() {
    if (assetPath != null) {
      return Lottie.asset(
        assetPath!,
        width: size * 0.7,
        height: size * 0.7,
        fit: BoxFit.contain,
        frameRate: FrameRate.max,
        errorBuilder: (context, error, stackTrace) {
          return Icon(fallbackIcon, size: size * 0.5, color: Colors.white);
        },
      );
    } else if (networkUrl != null) {
      return Lottie.network(
        networkUrl!,
        width: size * 0.7,
        height: size * 0.7,
        fit: BoxFit.contain,
        frameRate: FrameRate.max,
        errorBuilder: (context, error, stackTrace) {
          return Icon(fallbackIcon, size: size * 0.5, color: Colors.white);
        },
        frameBuilder: (context, child, composition) {
          if (composition == null) {
            return Icon(fallbackIcon, size: size * 0.5, color: Colors.white);
          }
          return child;
        },
      );
    }
    return Icon(fallbackIcon, size: size * 0.5, color: Colors.white);
  }
}
