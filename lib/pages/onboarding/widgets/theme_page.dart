import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:monefy_note_app/pages/onboarding/widgets/lottie_icon.dart';

class ThemePage extends StatefulWidget {
  final ThemeMode selectedTheme;
  final ValueChanged<ThemeMode> onSelect;

  const ThemePage({
    super.key,
    required this.selectedTheme,
    required this.onSelect,
  });

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _iconAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _previewAnimation;
  late Animation<double> _cardsAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _iconAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
    );

    _titleAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.15, 0.55, curve: Curves.easeOut),
    );

    _previewAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.3, 0.75, curve: Curves.easeOutCubic),
    );

    _cardsAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Theme selection page',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Spacer(),
            AnimatedBuilder(
              animation: _iconAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _iconAnimation.value,
                  child: Opacity(
                    opacity: _iconAnimation.value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: const LottieIcon(
                assetPath: 'assets/lottie/palette.json',
                fallbackIcon: Icons.palette_rounded,
                size: 120,
              ),
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _titleAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _titleAnimation.value.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - _titleAnimation.value)),
                    child: child,
                  ),
                );
              },
              child: Column(
                children: [
                  Text(
                    'onboarding.theme.title'.tr(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'onboarding.theme.subtitle'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _previewAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _previewAnimation.value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.9 + (_previewAnimation.value * 0.1),
                    child: child,
                  ),
                );
              },
              child: ThemePreviewCard(selectedTheme: widget.selectedTheme),
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _cardsAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _cardsAnimation.value.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - _cardsAnimation.value)),
                    child: child,
                  ),
                );
              },
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: widget.selectedTheme == ThemeMode.light,
                      label: 'Light theme',
                      child: ThemeOptionCard(
                        icon: Icons.light_mode_rounded,
                        label: 'onboarding.theme.light'.tr(),
                        isSelected: widget.selectedTheme == ThemeMode.light,
                        onTap: () => widget.onSelect(ThemeMode.light),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: widget.selectedTheme == ThemeMode.dark,
                      label: 'Dark theme',
                      child: ThemeOptionCard(
                        icon: Icons.dark_mode_rounded,
                        label: 'onboarding.theme.dark'.tr(),
                        isSelected: widget.selectedTheme == ThemeMode.dark,
                        onTap: () => widget.onSelect(ThemeMode.dark),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: widget.selectedTheme == ThemeMode.system,
                      label: 'System theme',
                      child: ThemeOptionCard(
                        icon: Icons.brightness_auto_rounded,
                        label: 'onboarding.theme.system'.tr(),
                        isSelected: widget.selectedTheme == ThemeMode.system,
                        onTap: () => widget.onSelect(ThemeMode.system),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

// Theme Preview Card
class ThemePreviewCard extends StatefulWidget {
  final ThemeMode selectedTheme;

  const ThemePreviewCard({super.key, required this.selectedTheme});

  @override
  State<ThemePreviewCard> createState() => _ThemePreviewCardState();
}

class _ThemePreviewCardState extends State<ThemePreviewCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.95), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 50),
    ]).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut));

    _rotateAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.02), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.02, end: 0.0), weight: 50),
    ]).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant ThemePreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTheme != widget.selectedTheme) {
      _animController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = widget.selectedTheme == ThemeMode.dark ||
        (widget.selectedTheme == ThemeMode.system &&
            brightness == Brightness.dark);

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: child,
          ),
        );
      },
      child: _buildCard(isDark),
    );
  }

  Widget _buildCard(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDark ? Colors.blue.shade700 : Colors.blue.shade500,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 10,
                      width: 80,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white70 : Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 8,
                      width: 50,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white30 : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white12 : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  size: 16,
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [Colors.blue.shade800, Colors.blue.shade900]
                    : [Colors.blue.shade400, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 8,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMiniListItem(isDark, Colors.green),
              const SizedBox(width: 8),
              _buildMiniListItem(isDark, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniListItem(bool isDark, Color accentColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                accentColor == Colors.green
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                size: 14,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 6,
                    width: 40,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white38 : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 8,
                    width: 30,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Theme Option Card
class ThemeOptionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemeOptionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<ThemeOptionCard> createState() => _ThemeOptionCardState();
}

class _ThemeOptionCardState extends State<ThemeOptionCard>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.2),
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 28, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: widget.isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
              ),
              if (widget.isSelected) ...[
                const SizedBox(height: 6),
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
