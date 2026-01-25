import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  final bool isLoading;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Theme-aware colors
    final overlayColor = isDark
        ? Colors.black.withValues(alpha: 0.6)
        : Colors.black.withValues(alpha: 0.4);
    final containerColor = isDark
        ? theme.colorScheme.surface.withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.95);
    final borderColor = isDark
        ? theme.colorScheme.outline.withValues(alpha: 0.2)
        : Colors.grey.withValues(alpha: 0.2);
    final progressColor = theme.colorScheme.primary;
    final textColor = theme.colorScheme.onSurface;

    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: true,
              child: AnimatedOpacity(
                opacity: isLoading ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  color: overlayColor,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: containerColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: borderColor,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progressColor,
                            ),
                            strokeWidth: 3,
                          ),
                        ),
                        if (message != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: containerColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              message!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
