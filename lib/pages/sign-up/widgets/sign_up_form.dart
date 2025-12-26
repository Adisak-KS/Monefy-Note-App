import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:monefy_note_app/pages/sign-in/widgets/auth_text_field.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({
    super.key,
    required this.nameController,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onSubmit,
    required this.staggeredItemBuilder,
  });

  final TextEditingController nameController;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onSubmit;
  final Widget Function(int index, Widget child) staggeredItemBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Name field
        staggeredItemBuilder(
          1,
          AuthTextField(
            label: 'auth.name'.tr(),
            hint: 'auth.name_hint'.tr(),
            prefixIcon: Icons.person_outline,
            controller: nameController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'auth.name_required'.tr();
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),

        // Username field (optional)
        staggeredItemBuilder(
          2,
          AuthTextField(
            label: 'auth.username'.tr(),
            hint: 'auth.username_hint'.tr(),
            prefixIcon: Icons.alternate_email,
            controller: usernameController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value != null && value.isNotEmpty && value.length < 3) {
                return 'auth.username_too_short'.tr();
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),

        // Email field
        staggeredItemBuilder(
          3,
          AuthTextField(
            label: 'auth.email'.tr(),
            hint: 'example@email.com',
            prefixIcon: Icons.email_outlined,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
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
        ),
        const SizedBox(height: 16),

        // Password field
        staggeredItemBuilder(
          4,
          AuthTextField(
            label: 'auth.password'.tr(),
            hint: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
            controller: passwordController,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'auth.password_required'.tr();
              }
              if (value.length < 8) {
                return 'auth.password_min_8'.tr();
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),

        // Confirm Password field
        staggeredItemBuilder(
          5,
          AuthTextField(
            label: 'auth.confirm_password'.tr(),
            hint: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
            controller: confirmPasswordController,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'auth.password_required'.tr();
              }
              if (value != passwordController.text) {
                return 'auth.password_not_match'.tr();
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
