import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

enum BiometricType {
  fingerprint,
  face,
  iris,
  none,
}

class BiometricService {
  // Singleton
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if device supports biometric authentication
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } on PlatformException {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.map(_mapBiometricType).toList();
    } on PlatformException {
      return [];
    }
  }

  BiometricType _mapBiometricType(dynamic localAuthBiometric) {
    final type = localAuthBiometric.toString();
    if (type.contains('fingerprint')) {
      return BiometricType.fingerprint;
    } else if (type.contains('face')) {
      return BiometricType.face;
    } else if (type.contains('iris')) {
      return BiometricType.iris;
    }
    return BiometricType.none;
  }

  /// Get primary biometric type (for display purposes)
  Future<BiometricType> getPrimaryBiometricType() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      final types = availableBiometrics.map(_mapBiometricType).toList();

      if (types.contains(BiometricType.face)) {
        return BiometricType.face;
      } else if (types.contains(BiometricType.fingerprint)) {
        return BiometricType.fingerprint;
      } else if (types.contains(BiometricType.iris)) {
        return BiometricType.iris;
      }
      return BiometricType.none;
    } on PlatformException {
      return BiometricType.none;
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticate({
    required String localizedReason,
    bool biometricOnly = true,
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: biometricOnly,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException {
      return false;
    }
  }

  /// Cancel authentication
  Future<bool> cancelAuthentication() async {
    return await _localAuth.stopAuthentication();
  }
}
