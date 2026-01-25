import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'skeleton/shimmer_wrapper.dart';

/// A cached network image avatar with shimmer loading and error fallback.
class CachedAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final IconData fallbackIcon;
  final Color? backgroundColor;
  final Color? iconColor;

  const CachedAvatar({
    super.key,
    this.imageUrl,
    this.size = 40,
    this.fallbackIcon = Icons.person,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.primaryContainer;
    final fgColor = iconColor ?? theme.colorScheme.onPrimaryContainer;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildFallbackAvatar(bgColor, fgColor);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: size / 2,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => ShimmerWrapper(
        child: CircleAvatar(
          radius: size / 2,
          backgroundColor: bgColor,
        ),
      ),
      errorWidget: (context, url, error) =>
          _buildFallbackAvatar(bgColor, fgColor),
    );
  }

  Widget _buildFallbackAvatar(Color bgColor, Color fgColor) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: bgColor,
      child: Icon(
        fallbackIcon,
        size: size * 0.5,
        color: fgColor,
      ),
    );
  }
}
