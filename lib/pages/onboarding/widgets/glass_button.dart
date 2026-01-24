import 'package:flutter/material.dart';
import 'package:monefy_note_app/core/theme/app_colors.dart';

class GlassButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool iconFirst;
  final bool isPrimary;
  final bool isLoading;
  final VoidCallback onTap;

  const GlassButton({
    super.key,
    required this.label,
    required this.icon,
    this.iconFirst = false,
    required this.isPrimary,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Glass button is designed for gradient backgrounds
    // Use contrast colors based on theme
    final overlayColor = isDark ? Colors.white : Colors.white;
    final primaryGradientColors = isDark
        ? [Colors.white, AppColors.lightButtonGradientEnd]
        : [Colors.white, AppColors.lightButtonGradientEnd];
    final primaryTextColor = isDark
        ? AppColors.defaultGradientDark[1]
        : AppColors.defaultGradientLight[1];

    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? LinearGradient(
                    colors: primaryGradientColors,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
            color:
                widget.isPrimary ? null : overlayColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: widget.isPrimary
                  ? overlayColor.withValues(alpha: 0.8)
                  : overlayColor.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: overlayColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: -2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: widget.isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.isPrimary
                            ? primaryTextColor
                            : overlayColor,
                      ),
                    ),
                  )
                : Row(
                    key: const ValueKey('content'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.iconFirst) ...[
                        Icon(
                          widget.icon,
                          size: 20,
                          color: widget.isPrimary
                              ? primaryTextColor
                              : overlayColor,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: theme.textTheme.titleMedium?.copyWith(
                              color: widget.isPrimary
                                  ? primaryTextColor
                                  : overlayColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (!widget.iconFirst) ...[
                        const SizedBox(width: 8),
                        Icon(
                          widget.icon,
                          size: 20,
                          color: widget.isPrimary
                              ? primaryTextColor
                              : overlayColor,
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
