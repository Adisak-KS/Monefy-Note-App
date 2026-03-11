import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:monefy_note_app/core/cubit/auth/auth_cubit.dart';
import 'package:monefy_note_app/core/cubit/auth/auth_state.dart';
import 'package:monefy_note_app/core/repositories/auth_repository.dart';
import 'package:monefy_note_app/core/widgets/loading_overlay.dart';
import 'package:monefy_note_app/core/widgets/network_status_banner.dart';
import 'package:monefy_note_app/injection.dart';
import 'package:monefy_note_app/pages/sign-in/widgets/animated_gradient_background.dart';
import 'package:easy_localization/easy_localization.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();
    context.read<AuthCubit>().forgotPassword(_emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => AuthCubit(getIt<AuthRepository>()),
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          state.when(
            initial: () {
              setState(() {
                _isLoading = false;
                _emailSent = true;
              });
            },
            loading: () => setState(() => _isLoading = true),
            authenticated: (_) {},
            unauthenticated: () => setState(() => _isLoading = false),
            error: (message) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            },
          );
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
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: _emailSent
                                ? _buildSuccessContent(theme)
                                : _buildFormContent(theme),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: IconButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              context.go('/sign-in');
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: 0.15),
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
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
      ),
    );
  }

  Widget _buildFormContent(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_reset_rounded,
            size: 64,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          const SizedBox(height: 24),
          Text(
            'auth.forgot_password'.tr(),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'auth.forgot_password_description'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 40),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'auth.email'.tr(),
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'auth.email_required'.tr();
              }
              if (!value.contains('@')) {
                return 'auth.email_invalid'.tr();
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleSubmit(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'auth.send_reset_link'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            size: 64,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'auth.email_sent'.tr(),
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'auth.check_email_description'.tr(),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _emailController.text.trim(),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => context.go('/reset-password'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'auth.enter_reset_code'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.go('/sign-in'),
          child: Text(
            'auth.back_to_sign_in'.tr(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
