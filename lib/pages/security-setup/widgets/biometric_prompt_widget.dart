import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monefy_note_app/core/services/biometric_service.dart';

class BiometricPromptWidget extends StatelessWidget {
  const BiometricPromptWidget({
    super.key,
    required this.biometricType,
    required this.onEnable,
    required this.onSkip,
    this.isLoading = false,
    this.errorMessage,
  });

  final BiometricType biometricType;
  final VoidCallback onEnable;
  final VoidCallback onSkip;
  final bool isLoading;
  final String? errorMessage;

  IconData get _biometricIcon {
    switch (biometricType) {
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

  String get _biometricLabel {
    switch (biometricType) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris Scan';
      case BiometricType.none:
        return 'Biometric';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: Icon(
            _biometricIcon,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 32),
        // Title
        Text(
          'Enable $_biometricLabel',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Use $_biometricLabel for quick and secure access to your financial data',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        // Error message
        if (errorMessage != null) ...[
          const SizedBox(height: 16),
          Text(
            errorMessage!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 14,
            ),
          ),
        ],
        const SizedBox(height: 48),
        // Enable button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      onEnable();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_biometricIcon, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'Enable $_biometricLabel',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Skip button
        TextButton(
          onPressed: isLoading
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onSkip();
                },
          child: Text(
            'Skip for now',
            style: TextStyle(
              color: Colors.white.withValues(alpha: isLoading ? 0.3 : 0.7),
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
