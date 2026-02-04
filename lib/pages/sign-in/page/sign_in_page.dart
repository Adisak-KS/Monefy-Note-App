import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:monefy_note_app/core/cubit/auth/auth_cubit.dart';
import 'package:monefy_note_app/core/cubit/auth/auth_state.dart';
import 'package:monefy_note_app/core/repositories/auth_repository.dart';
import 'package:monefy_note_app/core/services/preferences_service.dart';
import 'package:monefy_note_app/core/widgets/exit_confirmation_dialog.dart';
import 'package:monefy_note_app/core/widgets/loading_overlay.dart';
import 'package:monefy_note_app/core/widgets/network_status_banner.dart';
import 'package:monefy_note_app/injection.dart';
import 'package:monefy_note_app/pages/sign-in/widgets/animated_gradient_background.dart';
import 'package:monefy_note_app/pages/sign-in/widgets/remember_me_checkbox.dart';
import 'package:monefy_note_app/pages/sign-in/widgets/sign_in_button.dart';
import 'package:monefy_note_app/pages/sign-in/widgets/sign_in_form.dart';
import 'package:monefy_note_app/pages/sign-in/widgets/sign_in_header.dart';
import 'package:monefy_note_app/pages/sign-in/widgets/social_login_button.dart';
import 'package:monefy_note_app/pages/sign-in/widgets/terms_privacy_link.dart';
import 'package:monefy_note_app/core/utils/responsive.dart';
import 'package:easy_localization/easy_localization.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage>
    with TickerProviderStateMixin {
  late final AnimationController _staggerController;
  late final List<Animation<double>> _staggerAnimations;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isLoading = false;
  bool _showSuccess = false;
  bool _isDialogShowing = false;
  bool _rememberMe = false;

  static const int _itemCount = 9;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _staggerAnimations = List.generate(_itemCount, (index) {
      final start = index * 0.1;
      final end = start + 0.4;
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
    _emailController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();

    context.read<AuthCubit>().signIn(
          emailOrUsername: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  Future<void> _handleGoogleSignIn() async {
    HapticFeedback.lightImpact();
    // TODO: Implement Google sign in API call
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      await _navigateAfterSignIn();
    }
  }

  Future<void> _navigateAfterSignIn() async {
    final prefsService = PreferencesService();
    final securityConfigured = await prefsService.isSecurityConfigured();

    if (mounted) {
      if (securityConfigured) {
        // Security already configured, verify before going home
        context.go('/security-verify');
      } else {
        // First time, setup security
        context.go('/security-setup');
      }
    }
  }

  Future<bool> _onWillPop() async {
    // ป้องกันการเปิด Dialog ซ้ำเมื่อกด Back หลายครั้ง
    if (_isDialogShowing) return true;
    _isDialogShowing = true;

    final shouldExit = await showExitConfirmationDialog(context);

    _isDialogShowing = false;

    if (shouldExit) {
      SystemNavigator.pop();
    }
    return false;
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

    return BlocProvider(
      create: (_) => AuthCubit(getIt<AuthRepository>()),
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          state.when(
            initial: () {},
            loading: () => setState(() => _isLoading = true),
            authenticated: (user) {
              setState(() {
                _isLoading = false;
                _showSuccess = true;
              });
              Future.delayed(const Duration(milliseconds: 800), () {
                if (mounted) _navigateAfterSignIn();
              });
            },
            unauthenticated: () => setState(() => _isLoading = false),
            error: (message) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            },
          );
        },
        child: BackButtonListener(
      onBackButtonPressed: () async {
        await _onWillPop();
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
                child: Center(
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
                                height: isKeyboardOpen ? 20 : 60,
                              ),
                              _buildStaggeredItem(
                                0,
                                AnimatedScale(
                                  duration: const Duration(milliseconds: 300),
                                  scale: isKeyboardOpen ? 0.8 : 1.0,
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 300),
                                    opacity: isKeyboardOpen ? 0.7 : 1.0,
                                    child: const SignInHeader(),
                                  ),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: isKeyboardOpen ? 24 : 48,
                              ),
                              _buildStaggeredItem(
                                1,
                                SignInForm(
                                  emailController: _emailController,
                                  passwordController: _passwordController,
                                  onSubmit: _handleSignIn,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildStaggeredItem(
                                2,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    RememberMeCheckbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() => _rememberMe = value);
                                      },
                                    ),
                                    SignInForgotPassword(
                                      onTap: () {
                                        // TODO: Navigate to forgot password
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildStaggeredItem(
                                3,
                                SignInButton(
                                  isLoading: _isLoading,
                                  showSuccess: _showSuccess,
                                  onTap: _handleSignIn,
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: isKeyboardOpen ? 16 : 32,
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
                                              4,
                                              const SignInDivider(),
                                            ),
                                            const SizedBox(height: 32),
                                            _buildStaggeredItem(
                                              5,
                                              SocialLoginButton.google(
                                                label: 'auth.continue_with_google'.tr(),
                                                onTap: _handleGoogleSignIn,
                                              ),
                                            ),
                                            const SizedBox(height: 32),
                                            _buildStaggeredItem(
                                              6,
                                              SignInSignUpLink(
                                                onTap: () {
                                                  context.go('/sign-up');
                                                },
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            _buildStaggeredItem(
                                              7,
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
              ),
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
