import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:monefy_note_app/core/models/security_type.dart';
import 'package:monefy_note_app/core/widgets/network_status_banner.dart';
import 'package:monefy_note_app/pages/security-setup/bloc/security_setup_cubit.dart';
import 'package:monefy_note_app/pages/security-setup/bloc/security_setup_state.dart';
import 'package:monefy_note_app/pages/security-setup/widgets/biometric_prompt_widget.dart';
import 'package:monefy_note_app/pages/security-setup/widgets/password_input_widget.dart';
import 'package:monefy_note_app/pages/security-setup/widgets/pattern_input_widget.dart';
import 'package:monefy_note_app/pages/security-setup/widgets/pin_input_widget.dart';
import 'package:monefy_note_app/pages/security-setup/widgets/security_type_selector.dart';
import 'package:monefy_note_app/pages/sign-in/widgets/animated_gradient_background.dart';

class SecuritySetupPage extends StatelessWidget {
  const SecuritySetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SecuritySetupCubit()..initialize(),
      child: const _SecuritySetupView(),
    );
  }
}

class _SecuritySetupView extends StatelessWidget {
  const _SecuritySetupView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SecuritySetupCubit, SecuritySetupState>(
      listener: (context, state) {
        if (state is SecuritySetupCompleted) {
          context.go('/home');
        }
      },
      builder: (context, state) {
        return BackButtonListener(
          onBackButtonPressed: () async {
            if (state is SecuritySetupInProgress) {
              final cubit = context.read<SecuritySetupCubit>();
              if (state.step != SecuritySetupStep.selectType &&
                  state.step != SecuritySetupStep.biometricPrompt) {
                cubit.goBack();
                return true;
              }
            }
            return false;
          },
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: NetworkStatusBanner(
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                body: AnimatedGradientBackground(
                  child: SafeArea(
                    child: _buildContent(context, state),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, SecuritySetupState state) {
    if (state is SecuritySetupInitial) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (state is SecuritySetupInProgress) {
      return Stack(
        children: [
          // Main content
          _buildStepContent(context, state),
          // Back button (not on select type or biometric prompt)
          if (state.step != SecuritySetupStep.selectType &&
              state.step != SecuritySetupStep.biometricPrompt)
            Positioned(
              top: 8,
              left: 8,
              child: _BackButton(
                onTap: () => context.read<SecuritySetupCubit>().goBack(),
              ),
            ),
          // Step indicator
          if (state.step != SecuritySetupStep.biometricPrompt)
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: _StepIndicator(
                currentStep: _getStepIndex(state.step),
                totalSteps: 3,
              ),
            ),
        ],
      );
    }

    if (state is SecuritySetupError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<SecuritySetupCubit>().initialize();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  int _getStepIndex(SecuritySetupStep step) {
    switch (step) {
      case SecuritySetupStep.selectType:
        return 0;
      case SecuritySetupStep.enterCredential:
        return 1;
      case SecuritySetupStep.confirmCredential:
        return 2;
      case SecuritySetupStep.biometricPrompt:
      case SecuritySetupStep.completed:
        return 3;
    }
  }

  Widget _buildStepContent(
    BuildContext context,
    SecuritySetupInProgress state,
  ) {
    final cubit = context.read<SecuritySetupCubit>();

    switch (state.step) {
      case SecuritySetupStep.selectType:
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: SecurityTypeSelector(
              selectedType: state.selectedType,
              onTypeSelected: cubit.selectSecurityType,
              onContinue: cubit.proceedToEnterCredential,
            ),
          ),
        );

      case SecuritySetupStep.enterCredential:
        return _buildCredentialInput(
          context,
          state,
          isConfirming: false,
        );

      case SecuritySetupStep.confirmCredential:
        return _buildCredentialInput(
          context,
          state,
          isConfirming: true,
        );

      case SecuritySetupStep.biometricPrompt:
        return Center(
          child: BiometricPromptWidget(
            biometricType: state.biometricType!,
            onEnable: cubit.enableBiometric,
            onSkip: cubit.skipBiometric,
            isLoading: state.isLoading,
            errorMessage: state.errorMessage,
          ),
        );

      case SecuritySetupStep.completed:
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
    }
  }

  Widget _buildCredentialInput(
    BuildContext context,
    SecuritySetupInProgress state, {
    required bool isConfirming,
  }) {
    final cubit = context.read<SecuritySetupCubit>();

    switch (state.selectedType) {
      case SecurityType.pin:
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: PinInputWidget(
              title: isConfirming ? 'Confirm PIN' : 'Create PIN',
              subtitle: isConfirming
                  ? 'Enter your PIN again to confirm'
                  : 'Enter a 6-digit PIN',
              errorMessage: state.errorMessage,
              onErrorClear: cubit.clearError,
              onComplete: isConfirming
                  ? cubit.confirmPinOrPassword
                  : cubit.submitPinOrPassword,
            ),
          ),
        );

      case SecurityType.pattern:
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: PatternInputWidget(
              title: isConfirming ? 'Confirm Pattern' : 'Create Pattern',
              subtitle: isConfirming
                  ? 'Draw your pattern again to confirm'
                  : 'Connect at least 4 dots',
              errorMessage: state.errorMessage,
              onErrorClear: cubit.clearError,
              onComplete:
                  isConfirming ? cubit.confirmPattern : cubit.submitPattern,
            ),
          ),
        );

      case SecurityType.password:
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: PasswordInputWidget(
              title: isConfirming ? 'Confirm Password' : 'Create Password',
              subtitle: isConfirming
                  ? 'Enter your password again to confirm'
                  : 'Enter at least 6 characters',
              errorMessage: state.errorMessage,
              onErrorClear: cubit.clearError,
              onComplete: isConfirming
                  ? cubit.confirmPinOrPassword
                  : cubit.submitPinOrPassword,
            ),
          ),
        );
    }
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        final isCurrent = index == currentStep;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isCurrent ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
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
      onTap: widget.onTap,
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
