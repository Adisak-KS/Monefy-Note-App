import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monefy_note_app/core/theme/app_colors.dart';

class SignInButton extends StatefulWidget {
  const SignInButton({
    super.key,
    required this.isLoading,
    required this.onTap,
    this.showSuccess = false,
  });

  final bool isLoading;
  final bool showSuccess;
  final VoidCallback onTap;

  @override
  State<SignInButton> createState() => _SignInButtonState();
}

class _SignInButtonState extends State<SignInButton>
    with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final AnimationController _successController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _successScaleAnimation;
  late final Animation<double> _checkAnimation;

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

    _successController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _successScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );
  }

  @override
  void didUpdateWidget(SignInButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showSuccess && !oldWidget.showSuccess) {
      _successController.forward();
      HapticFeedback.heavyImpact();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: !widget.isLoading,
      label: widget.showSuccess
          ? 'Sign in successful'
          : widget.isLoading
              ? 'Signing in, please wait'
              : 'auth.sign_in'.tr(),
      child: GestureDetector(
        onTapDown: widget.isLoading ? null : (_) => _scaleController.forward(),
        onTapUp: widget.isLoading ? null : (_) => _scaleController.reverse(),
        onTapCancel: widget.isLoading ? null : () => _scaleController.reverse(),
        onTap: widget.isLoading
            ? null
            : () {
                HapticFeedback.mediumImpact();
                widget.onTap();
              },
        child: AnimatedBuilder(
        animation: Listenable.merge([_scaleController, _successController]),
        builder: (context, child) {
          return Transform.scale(
            scale: widget.showSuccess
                ? _successScaleAnimation.value
                : _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.showSuccess
                  ? [Colors.green.shade400, Colors.green.shade600]
                  : [Colors.white, const Color(0xFFF0F0F0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: widget.showSuccess
                    ? Colors.green.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.15),
                blurRadius: widget.showSuccess ? 16 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: widget.showSuccess
                  ? AnimatedBuilder(
                      animation: _checkAnimation,
                      builder: (context, _) {
                        return Transform.scale(
                          scale: _checkAnimation.value,
                          child: const Icon(
                            Icons.check_rounded,
                            key: ValueKey('success'),
                            color: Colors.white,
                            size: 28,
                          ),
                        );
                      },
                    )
                  : widget.isLoading
                      ? SizedBox(
                          key: const ValueKey('loading'),
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.defaultGradientLight[0],
                            ),
                          ),
                        )
                      : Row(
                          key: const ValueKey('text'),
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.login_rounded,
                              color: AppColors.defaultGradientLight[0],
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'auth.sign_in'.tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppColors.defaultGradientLight[0],
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}
