import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:monefy_note_app/pages/onboarding/widgets/glass_card.dart';
import 'package:monefy_note_app/pages/onboarding/widgets/lottie_icon.dart';

class LanguagePage extends StatefulWidget {
  final Locale selectedLocale;
  final ValueChanged<Locale> onSelect;

  const LanguagePage({
    super.key,
    required this.selectedLocale,
    required this.onSelect,
  });

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _iconAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _cardsAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _iconAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
    );

    _titleAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
    );

    _cardsAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
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
      label: 'Language selection page',
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
                assetPath: 'assets/lottie/language.json',
                fallbackIcon: Icons.translate_rounded,
                size: 120,
              ),
            ),
            const SizedBox(height: 32),
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
                    'onboarding.language.title'.tr(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'onboarding.language.subtitle'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
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
                      selected: widget.selectedLocale.languageCode == 'th',
                      label: 'Thai language',
                      child: GlassCard(
                        emoji: 'TH',
                        label: 'ไทย',
                        isSelected: widget.selectedLocale.languageCode == 'th',
                        onTap: () => widget.onSelect(const Locale('th', 'TH')),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: widget.selectedLocale.languageCode == 'en',
                      label: 'English language',
                      child: GlassCard(
                        emoji: 'EN',
                        label: 'English',
                        isSelected: widget.selectedLocale.languageCode == 'en',
                        onTap: () => widget.onSelect(const Locale('en', 'US')),
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
