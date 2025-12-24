import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TermsPrivacyLink extends StatelessWidget {
  const TermsPrivacyLink({
    super.key,
    this.onTermsTap,
    this.onPrivacyTap,
  });

  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${'auth.terms_of_service'.tr()} ${'auth.and'.tr()} ${'auth.privacy_policy'.tr()}',
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Text(
            'auth.terms_agree'.tr(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(width: 4),
          _LinkText(
            text: 'auth.terms_of_service'.tr(),
            onTap: onTermsTap,
          ),
          Text(
            ' ${'auth.and'.tr()} ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
          ),
          _LinkText(
            text: 'auth.privacy_policy'.tr(),
            onTap: onPrivacyTap,
          ),
        ],
      ),
    );
  }
}

class _LinkText extends StatefulWidget {
  const _LinkText({
    required this.text,
    this.onTap,
  });

  final String text;
  final VoidCallback? onTap;

  @override
  State<_LinkText> createState() => _LinkTextState();
}

class _LinkTextState extends State<_LinkText> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 150),
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: _isPressed
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: _isPressed
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.85),
            ),
        child: Text(widget.text),
      ),
    );
  }
}
