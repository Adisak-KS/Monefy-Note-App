import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:monefy_note_app/core/services/preferences_service.dart';
import 'package:monefy_note_app/core/widgets/loading_overlay.dart';
import 'package:monefy_note_app/core/widgets/network_status_banner.dart';
import 'package:monefy_note_app/pages/sign-in/widgets/animated_gradient_background.dart';
import 'package:monefy_note_app/pages/sign-in/widgets/sign_in_form.dart';
import 'package:monefy_note_app/pages/sign-in/widgets/social_login_button.dart';
import 'package:monefy_note_app/pages/sign-in/widgets/terms_privacy_link.dart';
import 'package:monefy_note_app/pages/sign-up/widgets/sign_up_header.dart';
import 'package:monefy_note_app/pages/sign-up/widgets/sign_up_form.dart';
import 'package:monefy_note_app/pages/sign-up/widgets/sign_up_button.dart';
import 'package:monefy_note_app/pages/sign-up/widgets/sign_up_sign_in_link.dart';
import 'package:monefy_note_app/core/utils/responsive.dart';
import 'package:easy_localization/easy_localization.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with TickerProviderStateMixin {
  late final AnimationController _staggerController;
  late final List<Animation<double>> _staggerAnimations;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isLoading = false;
  bool _showSuccess = false;

  static const int _itemCount = 11;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _staggerAnimations = List.generate(_itemCount, (index) {
      final start = index * 0.08;
      final end = start + 0.35;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(
            start.clamp(0.0, 1.0),
            end.clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    // TODO: Implement actual sign up API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _showSuccess = true;
      });

      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        // After sign up, always go to security setup (new user)
        context.go('/security-setup');
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    HapticFeedback.lightImpact();
    // TODO: Implement Google sign up API call
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      // Check if security is already configured
      final prefsService = PreferencesService();
      final securityConfigured = await prefsService.isSecurityConfigured();

      if (mounted) {
        if (securityConfigured) {
          context.go('/security-verify');
        } else {
          context.go('/security-setup');
        }
      }
    }
  }

  void _handleBack() {
    context.go('/sign-in');
  }

  Widget _buildStaggeredItem(int index, Widget child) {
    return AnimatedBuilder(
      animation: _staggerAnimations[index],
      builder: (context, widget) {
        final value = _staggerAnimations[index].value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: widget,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = bottomInset > 0;

    return BackButtonListener(
      onBackButtonPressed: () async {
        _handleBack();
        return true;
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: NetworkStatusBanner(
          child: LoadingOverlay(
            isLoading: _isLoading,
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              body: AnimatedGradientBackground(
                child: SafeArea(
                  child: Stack(
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: Responsive.maxContentWidth(context),
                          ),
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            padding: Responsive.horizontalPadding(context),
                            child: AnimatedPadding(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.only(
                                top: isKeyboardOpen ? 20 : 0,
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      height: isKeyboardOpen ? 10 : 40,
                                    ),
                                _buildStaggeredItem(
                                  0,
                                  AnimatedScale(
                                    duration: const Duration(milliseconds: 300),
                                    scale: isKeyboardOpen ? 0.7 : 1.0,
                                    child: AnimatedOpacity(
                                      duration: const Duration(milliseconds: 300),
                                      opacity: isKeyboardOpen ? 0.5 : 1.0,
                                      child: const SignUpHeader(),
                                    ),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: isKeyboardOpen ? 16 : 32,
                                ),
                                SignUpForm(
                                  nameController: _nameController,
                                  usernameController: _usernameController,
                                  emailController: _emailController,
                                  passwordController: _passwordController,
                                  confirmPasswordController: _confirmPasswordController,
                                  onSubmit: _handleSignUp,
                                  staggeredItemBuilder: _buildStaggeredItem,
                                ),
                                const SizedBox(height: 24),
                                _buildStaggeredItem(
                                  6,
                                  SignUpButton(
                                    isLoading: _isLoading,
                                    showSuccess: _showSuccess,
                                    onTap: _handleSignUp,
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: isKeyboardOpen ? 16 : 24,
                                ),
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: isKeyboardOpen ? 0.0 : 1.0,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    height: isKeyboardOpen ? 0 : null,
                                    child: isKeyboardOpen
                                        ? const SizedBox.shrink()
                                        : Column(
                                            children: [
                                              _buildStaggeredItem(
                                                7,
                                                const SignInDivider(),
                                              ),
                                              const SizedBox(height: 24),
                                              _buildStaggeredItem(
                                                8,
                                                SocialLoginButton.google(
                                                  label: 'auth.sign_up_with_google'.tr(),
                                                  onTap: _handleGoogleSignUp,
                                                ),
                                              ),
                                              const SizedBox(height: 24),
                                              _buildStaggeredItem(
                                                9,
                                                SignUpSignInLink(
                                                  onTap: () {
                                                    context.go('/sign-in');
                                                  },
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              _buildStaggeredItem(
                                                10,
                                                TermsPrivacyLink(
                                                  onTermsTap: () {
                                                    // TODO: Open terms of service
                                                  },
                                                  onPrivacyTap: () {
                                                    // TODO: Open privacy policy
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                                    SizedBox(height: isKeyboardOpen ? 20 : 32),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Back button
                      Positioned(
                        top: 8,
                        left: 8,
                        child: _BackButton(
                          onTap: () => context.go('/sign-in'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatefulWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}
