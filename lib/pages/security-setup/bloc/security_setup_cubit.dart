import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monefy_note_app/core/models/security_type.dart';
import 'package:monefy_note_app/core/services/biometric_service.dart';
import 'package:monefy_note_app/core/services/preferences_service.dart';
import 'package:monefy_note_app/core/services/secure_storage_service.dart';
import 'package:monefy_note_app/pages/security-setup/bloc/security_setup_state.dart';

class SecuritySetupCubit extends Cubit<SecuritySetupState> {
  SecuritySetupCubit() : super(SecuritySetupInitial());

  final PreferencesService _prefsService = PreferencesService();
  final SecureStorageService _secureStorage = SecureStorageService();
  final BiometricService _biometricService = BiometricService();

  Future<void> initialize() async {
    final biometricAvailable = await _biometricService.isBiometricAvailable();
    final biometricType = await _biometricService.getPrimaryBiometricType();

    emit(SecuritySetupInProgress(
      step: SecuritySetupStep.selectType,
      selectedType: SecurityType.pin,
      biometricAvailable: biometricAvailable,
      biometricType: biometricType,
    ));
  }

  void selectSecurityType(SecurityType type) {
    final currentState = state;
    if (currentState is SecuritySetupInProgress) {
      HapticFeedback.selectionClick();
      emit(currentState.copyWith(
        selectedType: type,
        clearError: true,
        clearCredential: true,
      ));
    }
  }

  void proceedToEnterCredential() {
    final currentState = state;
    if (currentState is SecuritySetupInProgress) {
      HapticFeedback.lightImpact();
      emit(currentState.copyWith(
        step: SecuritySetupStep.enterCredential,
        clearError: true,
        clearCredential: true,
      ));
    }
  }

  /// Submit PIN or Password credential
  void submitPinOrPassword(String credential) {
    final currentState = state;
    if (currentState is SecuritySetupInProgress) {
      // Validate credential
      final error = _validatePinOrPassword(
        credential,
        currentState.selectedType,
      );
      if (error != null) {
        HapticFeedback.heavyImpact();
        emit(currentState.copyWith(errorMessage: error));
        return;
      }

      HapticFeedback.lightImpact();
      emit(currentState.copyWith(
        step: SecuritySetupStep.confirmCredential,
        enteredPinOrPassword: credential,
        clearError: true,
      ));
    }
  }

  /// Submit Pattern credential
  void submitPattern(List<int> pattern) {
    final currentState = state;
    if (currentState is SecuritySetupInProgress) {
      // Validate pattern
      if (pattern.length < 4) {
        HapticFeedback.heavyImpact();
        emit(currentState.copyWith(errorMessage: 'Connect at least 4 dots'));
        return;
      }

      HapticFeedback.lightImpact();
      emit(currentState.copyWith(
        step: SecuritySetupStep.confirmCredential,
        enteredPattern: pattern,
        clearError: true,
      ));
    }
  }

  /// Confirm PIN or Password credential
  Future<void> confirmPinOrPassword(String credential) async {
    final currentState = state;
    if (currentState is SecuritySetupInProgress) {
      // Check if credentials match
      if (credential != currentState.enteredPinOrPassword) {
        HapticFeedback.heavyImpact();
        emit(currentState.copyWith(
          errorMessage: _getMismatchError(currentState.selectedType),
        ));
        return;
      }

      await _saveCredentialAndProceed(currentState, credential: credential);
    }
  }

  /// Confirm Pattern credential
  Future<void> confirmPattern(List<int> pattern) async {
    final currentState = state;
    if (currentState is SecuritySetupInProgress) {
      // Check if patterns match
      if (!listEquals(pattern, currentState.enteredPattern)) {
        HapticFeedback.heavyImpact();
        emit(currentState.copyWith(errorMessage: 'Patterns don\'t match'));
        return;
      }

      await _saveCredentialAndProceed(currentState, pattern: pattern);
    }
  }

  Future<void> _saveCredentialAndProceed(
    SecuritySetupInProgress currentState, {
    String? credential,
    List<int>? pattern,
  }) async {
    emit(currentState.copyWith(isLoading: true));

    try {
      // Save credential based on type
      if (pattern != null) {
        await _secureStorage.savePatternCredential(pattern);
      } else if (credential != null) {
        await _secureStorage.saveSecurityCredential(credential);
      }

      await _prefsService.setSecurityType(currentState.selectedType);

      HapticFeedback.mediumImpact();

      // Check if biometric is available
      if (currentState.biometricAvailable) {
        emit(currentState.copyWith(
          step: SecuritySetupStep.biometricPrompt,
          isLoading: false,
          clearError: true,
        ));
      } else {
        // No biometric, complete setup
        await _completeSetup(false);
      }
    } catch (e) {
      emit(currentState.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> enableBiometric() async {
    final currentState = state;
    if (currentState is SecuritySetupInProgress) {
      emit(currentState.copyWith(isLoading: true));

      try {
        // Test biometric authentication
        final authenticated = await _biometricService.authenticate(
          localizedReason: 'Verify your identity to enable biometric',
        );

        if (authenticated) {
          await _completeSetup(true);
        } else {
          HapticFeedback.heavyImpact();
          emit(currentState.copyWith(
            isLoading: false,
            errorMessage: 'Biometric authentication failed',
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  Future<void> skipBiometric() async {
    HapticFeedback.lightImpact();
    await _completeSetup(false);
  }

  Future<void> _completeSetup(bool biometricEnabled) async {
    final currentState = state;
    if (currentState is SecuritySetupInProgress) {
      await _prefsService.setBiometricEnabled(biometricEnabled);
      await _prefsService.setSecurityConfigured(true);

      HapticFeedback.mediumImpact();

      emit(SecuritySetupCompleted(
        securityType: currentState.selectedType,
        biometricEnabled: biometricEnabled,
      ));
    }
  }

  void goBack() {
    final currentState = state;
    if (currentState is SecuritySetupInProgress) {
      HapticFeedback.lightImpact();
      switch (currentState.step) {
        case SecuritySetupStep.enterCredential:
          emit(currentState.copyWith(
            step: SecuritySetupStep.selectType,
            clearError: true,
            clearCredential: true,
          ));
          break;
        case SecuritySetupStep.confirmCredential:
          emit(currentState.copyWith(
            step: SecuritySetupStep.enterCredential,
            clearError: true,
          ));
          break;
        case SecuritySetupStep.biometricPrompt:
          // Can't go back from biometric prompt, credential is already saved
          break;
        default:
          break;
      }
    }
  }

  void clearError() {
    final currentState = state;
    if (currentState is SecuritySetupInProgress) {
      emit(currentState.copyWith(clearError: true));
    }
  }

  String? _validatePinOrPassword(String credential, SecurityType type) {
    switch (type) {
      case SecurityType.pin:
        if (credential.length != 6) {
          return 'PIN must be 6 digits';
        }
        if (!RegExp(r'^\d{6}$').hasMatch(credential)) {
          return 'PIN must contain only numbers';
        }
        break;
      case SecurityType.password:
        if (credential.length < 6) {
          return 'Password must be at least 6 characters';
        }
        break;
      case SecurityType.pattern:
        // Pattern is handled separately
        break;
    }
    return null;
  }

  String _getMismatchError(SecurityType type) {
    switch (type) {
      case SecurityType.pin:
        return 'PINs don\'t match';
      case SecurityType.pattern:
        return 'Patterns don\'t match';
      case SecurityType.password:
        return 'Passwords don\'t match';
    }
  }
}
