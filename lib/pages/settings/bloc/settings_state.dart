import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../core/models/security_type.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  final ThemeMode themeMode;
  final Locale locale;
  final bool isSecurityEnabled;
  final SecurityType? securityType;
  final bool isBiometricEnabled;
  final String appVersion;

  const SettingsLoaded({
    required this.themeMode,
    required this.locale,
    required this.isSecurityEnabled,
    this.securityType,
    required this.isBiometricEnabled,
    required this.appVersion,
  });

  @override
  List<Object?> get props => [
        themeMode,
        locale,
        isSecurityEnabled,
        securityType,
        isBiometricEnabled,
        appVersion,
      ];

  SettingsLoaded copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? isSecurityEnabled,
    SecurityType? securityType,
    bool? isBiometricEnabled,
    String? appVersion,
  }) {
    return SettingsLoaded(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      isSecurityEnabled: isSecurityEnabled ?? this.isSecurityEnabled,
      securityType: securityType ?? this.securityType,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object> get props => [message];
}
