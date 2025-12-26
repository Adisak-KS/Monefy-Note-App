import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:monefy_note_app/core/models/security_type.dart';
import 'package:monefy_note_app/core/services/biometric_service.dart';
import 'package:monefy_note_app/core/services/preferences_service.dart';
import 'package:monefy_note_app/core/services/secure_storage_service.dart';
import 'package:monefy_note_app/core/widgets/network_status_banner.dart';
import 'package:monefy_note_app/pages/security-setup/widgets/password_input_widget.dart';
import 'package:monefy_note_app/pages/security-setup/widgets/pattern_input_widget.dart';
import 'package:monefy_note_app/pages/security-setup/widgets/pin_input_widget.dart';
import 'package:monefy_note_app/pages/sign-in/widgets/animated_gradient_background.dart';

class SecurityVerifyPage extends StatefulWidget {
  const SecurityVerifyPage({super.key});

  @override
  State<SecurityVerifyPage> createState() => _SecurityVerifyPageState();
}

class _SecurityVerifyPageState extends State<SecurityVerifyPage> {
  final PreferencesService _prefsService = PreferencesService();
  final SecureStorageService _secureStorage = SecureStorageService();
  final BiometricService _biometricService = BiometricService();

  SecurityType? _securityType;
  bool _biometricEnabled = false;
  BiometricType? _biometricType;
  String? _errorMessage;
  bool _isLoading = true;
  int _failedAttempts = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final securityType = await _prefsService.getSecurityType();
    final biometricEnabled = await _prefsService.isBiometricEnabled();
    final biometricType = await _biometricService.getPrimaryBiometricType();

    setState(() {
      _securityType = securityType;
      _biometricEnabled = biometricEnabled;
      _biometricType = biometricType;
      _isLoading = false;
    });

    // Try biometric first if enabled
    if (biometricEnabled && biometricType != BiometricType.none) {
      await _authenticateWithBiometric();
    }
  }

  Future<void> _authenticateWithBiometric() async {
    try {
      final authenticated = await _biometricService.authenticate(
        localizedReason: 'Verify your identity to access the app',
      );
      if (authenticated && mounted) {
        context.go('/home');
      }
    } catch (_) {
      // Biometric failed, user will need to use PIN/Pattern/Password
    }
  }

  Future<void> _verifyCredential(String credential) async {
    final verified = await _secureStorage.verifyCredential(credential);
    if (verified && mounted) {
      HapticFeedback.mediumImpact();
      context.go('/home');
    } else {
      _handleFailedAttempt();
    }
  }

  Future<void> _verifyPattern(List<int> pattern) async {
    final verified = await _secureStorage.verifyPatternCredential(pattern);
    if (verified && mounted) {
      HapticFeedback.mediumImpact();
      context.go('/home');
    } else {
      _handleFailedAttempt();
    }
  }

  void _handleFailedAttempt() {
    setState(() {
      _failedAttempts++;
      if (_failedAttempts >= 3) {
        _errorMessage = 'Too many failed attempts. Please try again.';
      } else {
        _errorMessage = _getErrorMessage();
      }
    });
  }

  String _getErrorMessage() {
    switch (_securityType) {
      case SecurityType.pin:
        return 'Incorrect PIN';
      case SecurityType.pattern:
        return 'Incorrect pattern';
      case SecurityType.password:
        return 'Incorrect password';
      default:
        return 'Verification failed';
    }
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackButtonListener(
      onBackButtonPressed: () async {
        // Prevent going back from verify page
        return false;
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: NetworkStatusBanner(
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: AnimatedGradientBackground(
              child: SafeArea(
                child: _buildContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return Stack(
      children: [
        // Main content
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: _buildVerifyInput(),
          ),
        ),
        // Biometric button (if enabled)
        if (_biometricEnabled && _biometricType != BiometricType.none)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: _BiometricButton(
                biometricType: _biometricType!,
                onTap: _authenticateWithBiometric,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVerifyInput() {
    switch (_securityType) {
      case SecurityType.pin:
        return PinInputWidget(
          title: 'Enter PIN',
          subtitle: 'Enter your 6-digit PIN to continue',
          errorMessage: _errorMessage,
          onErrorClear: _clearError,
          onComplete: _verifyCredential,
        );

      case SecurityType.pattern:
        return PatternInputWidget(
          title: 'Draw Pattern',
          subtitle: 'Draw your pattern to continue',
          errorMessage: _errorMessage,
          onErrorClear: _clearError,
          onComplete: _verifyPattern,
        );

      case SecurityType.password:
        return PasswordInputWidget(
          title: 'Enter Password',
          subtitle: 'Enter your password to continue',
          errorMessage: _errorMessage,
          onErrorClear: _clearError,
          onComplete: _verifyCredential,
        );

      default:
        return const Center(
          child: Text(
            'Security not configured',
            style: TextStyle(color: Colors.white),
          ),
        );
    }
  }
}

class _BiometricButton extends StatefulWidget {
  const _BiometricButton({
    required this.biometricType,
    required this.onTap,
  });

  final BiometricType biometricType;
  final VoidCallback onTap;

  @override
  State<_BiometricButton> createState() => _BiometricButtonState();
}

class _BiometricButtonState extends State<_BiometricButton>
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

  IconData get _icon {
    switch (widget.biometricType) {
      case BiometricType.face:
        return Icons.face;
      case BiometricType.fingerprint:
        return Icons.fingerprint;
      case BiometricType.iris:
        return Icons.remove_red_eye;
      case BiometricType.none:
        return Icons.security;
    }
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _icon,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Use Biometric',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
