import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:monefy_note_app/core/theme/app_colors.dart';
import 'package:monefy_note_app/pages/sign-in/widgets/auth_text_field.dart';
import 'package:monefy_note_app/pages/sign-in/widgets/social_login_button.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with TickerProviderStateMixin {
  late final AnimationController _gradientController;
  late final AnimationController _bubbleController;
  late final AnimationController _entranceController;
  late final List<_Bubble> _bubbles;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _bubbleController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();

    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _bubbles = List.generate(6, (_) => _Bubble.random());
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _bubbleController.dispose();
    _entranceController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    // TODO: Implement actual sign in
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      context.go('/home');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    HapticFeedback.lightImpact();
    // TODO: Implement Google sign in
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_gradientController, _bubbleController]),
        builder: (context, child) => _buildBackground(child!),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AnimatedBuilder(
              animation: _entranceController,
              builder: (context, child) {
                final opacity = _entranceController.value.clamp(0.0, 1.0);
                final translateY = 30 * (1 - _entranceController.value);
                return Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(0, translateY),
                    child: child,
                  ),
                );
              },
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    _buildHeader(),
                    const SizedBox(height: 48),
                    _buildSocialLogin(),
                    const SizedBox(height: 32),
                    _buildDivider(),
                    const SizedBox(height: 32),
                    _buildEmailPasswordForm(),
                    const SizedBox(height: 16),
                    _buildForgotPassword(),
                    const SizedBox(height: 24),
                    _buildSignInButton(),
                    const SizedBox(height: 32),
                    _buildSignUpLink(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'auth.welcome_back'.tr(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'auth.sign_in_subtitle'.tr(),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return SocialLoginButton.google(
      label: 'auth.continue_with_google'.tr(),
      onTap: _handleGoogleSignIn,
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'auth.or'.tr(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailPasswordForm() {
    return Column(
      children: [
        AuthTextField(
          label: 'auth.email'.tr(),
          hint: 'example@email.com',
          prefixIcon: Icons.email_outlined,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'auth.email_required'.tr();
            }
            if (!value.contains('@')) {
              return 'auth.email_invalid'.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        AuthTextField(
          label: 'auth.password'.tr(),
          hint: '••••••••',
          prefixIcon: Icons.lock_outline_rounded,
          isPassword: true,
          controller: _passwordController,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleSignIn(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'auth.password_required'.tr();
            }
            if (value.length < 6) {
              return 'auth.password_too_short'.tr();
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          // TODO: Navigate to forgot password
        },
        child: Text(
          'auth.forgot_password'.tr(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleSignIn,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF0F0F0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.defaultGradientLight[0],
                    ),
                  ),
                )
              : Text(
                  'auth.sign_in'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.defaultGradientLight[0],
                        fontWeight: FontWeight.w600,
                      ),
                ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'auth.no_account'.tr(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            // TODO: Navigate to sign up
          },
          child: Text(
            'auth.sign_up'.tr(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackground(Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColors.defaultGradientDark : AppColors.defaultGradientLight;

    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(
              -1 + _gradientController.value * 0.5,
              -1 + _gradientController.value * 0.5,
            ),
            end: Alignment(
              1 - _gradientController.value * 0.5,
              1 - _gradientController.value * 0.5,
            ),
            colors: colors,
          ),
        ),
        child: Stack(
          children: [
            ..._bubbles.map((bubble) => _buildBubble(bubble)),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(_Bubble bubble) {
    final progress = (_bubbleController.value + bubble.offset) % 1.0;
    final yPos = 1.0 - progress;
    final screenSize = MediaQuery.of(context).size;

    return Positioned(
      left: bubble.x * screenSize.width,
      top: yPos * screenSize.height * 1.2 - 50,
      child: Opacity(
        opacity: bubble.opacity * (1 - (progress * 0.5)),
        child: Container(
          width: bubble.size,
          height: bubble.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.08),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _Bubble {
  final double x;
  final double size;
  final double opacity;
  final double offset;

  _Bubble({
    required this.x,
    required this.size,
    required this.opacity,
    required this.offset,
  });

  factory _Bubble.random() {
    final random = Random();
    return _Bubble(
      x: random.nextDouble(),
      size: 20 + random.nextDouble() * 50,
      opacity: 0.2 + random.nextDouble() * 0.3,
      offset: random.nextDouble(),
    );
  }
}
