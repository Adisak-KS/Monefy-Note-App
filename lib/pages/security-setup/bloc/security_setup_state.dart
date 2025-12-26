import 'package:equatable/equatable.dart';
import 'package:monefy_note_app/core/models/security_type.dart';
import 'package:monefy_note_app/core/services/biometric_service.dart';

enum SecuritySetupStep {
  selectType,
  enterCredential,
  confirmCredential,
  biometricPrompt,
  completed,
}

abstract class SecuritySetupState extends Equatable {
  const SecuritySetupState();

  @override
  List<Object?> get props => [];
}

class SecuritySetupInitial extends SecuritySetupState {}

class SecuritySetupInProgress extends SecuritySetupState {
  final SecuritySetupStep step;
  final SecurityType selectedType;
  final String? enteredPinOrPassword;
  final List<int>? enteredPattern;
  final String? errorMessage;
  final bool isLoading;
  final BiometricType? biometricType;
  final bool biometricAvailable;

  const SecuritySetupInProgress({
    required this.step,
    required this.selectedType,
    this.enteredPinOrPassword,
    this.enteredPattern,
    this.errorMessage,
    this.isLoading = false,
    this.biometricType,
    this.biometricAvailable = false,
  });

  SecuritySetupInProgress copyWith({
    SecuritySetupStep? step,
    SecurityType? selectedType,
    String? enteredPinOrPassword,
    List<int>? enteredPattern,
    String? errorMessage,
    bool? isLoading,
    BiometricType? biometricType,
    bool? biometricAvailable,
    bool clearError = false,
    bool clearCredential = false,
  }) {
    return SecuritySetupInProgress(
      step: step ?? this.step,
      selectedType: selectedType ?? this.selectedType,
      enteredPinOrPassword: clearCredential
          ? null
          : (enteredPinOrPassword ?? this.enteredPinOrPassword),
      enteredPattern:
          clearCredential ? null : (enteredPattern ?? this.enteredPattern),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
      biometricType: biometricType ?? this.biometricType,
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
    );
  }

  @override
  List<Object?> get props => [
        step,
        selectedType,
        enteredPinOrPassword,
        enteredPattern,
        errorMessage,
        isLoading,
        biometricType,
        biometricAvailable,
      ];
}

class SecuritySetupCompleted extends SecuritySetupState {
  final SecurityType securityType;
  final bool biometricEnabled;

  const SecuritySetupCompleted({
    required this.securityType,
    required this.biometricEnabled,
  });

  @override
  List<Object?> get props => [securityType, biometricEnabled];
}

class SecuritySetupError extends SecuritySetupState {
  final String message;

  const SecuritySetupError(this.message);

  @override
  List<Object?> get props => [message];
}
