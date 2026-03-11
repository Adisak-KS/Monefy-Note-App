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

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();
    context.read<AuthCubit>().resetPassword(
          token: _tokenController.text.trim(),
          newPassword: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => AuthCubit(getIt<AuthRepository>()),
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          state.when(
            initial: () => setState(() => _isLoading = false),
            loading: () => setState(() => _isLoading = true),
            authenticated: (_) {},
            unauthenticated: () {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('auth.password_reset_success'.tr())),
              );
              context.go('/sign-in');
            },
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
                            child: _buildFormContent(theme),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: IconButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              context.go('/forgot-password');
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
            Icons.password_rounded,
            size: 64,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          const SizedBox(height: 24),
          Text(
            'auth.reset_password'.tr(),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'auth.reset_password_description'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 40),
          // Reset token field
          TextFormField(
            controller: _tokenController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(
              hint: 'auth.reset_token'.tr(),
              icon: Icons.vpn_key_outlined,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'auth.token_required'.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // New password field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(
              hint: 'auth.new_password'.tr(),
              icon: Icons.lock_outline,
            ).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
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
          const SizedBox(height: 16),
          // Confirm password field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(
              hint: 'auth.confirm_password'.tr(),
              icon: Icons.lock_outline,
            ).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (value) {
              if (value != _passwordController.text) {
                return 'auth.passwords_dont_match'.tr();
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
                'auth.reset_password'.tr(),
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
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
      prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.7)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.white),
      ),
    );
  }
}
