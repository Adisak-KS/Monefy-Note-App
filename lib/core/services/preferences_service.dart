import 'package:flutter/material.dart';
import 'package:monefy_note_app/core/models/security_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _keyFirstLaunch = 'first_launch_complete';
  static const _keyThemeMode = 'theme_mode';
  static const _keyLocaleCode = 'locale_code';
  static const _keyPrivacyPolicyAccepted = 'privacy_policy_accepted';
  static const _keySecurityConfigured = 'security_configured';
  static const _keySecurityType = 'security_type';
  static const _keyBiometricEnabled = 'biometric_enabled';

  // Singleton
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // First Launch
  Future<bool> isFirstLaunch() async {
    final p = await prefs;
    return !(p.getBool(_keyFirstLaunch) ?? false);
  }

  Future<void> setFirstLaunchComplete() async {
    final p = await prefs;
    await p.setBool(_keyFirstLaunch, true);
  }

  // Theme Mode
  Future<void> saveThemeMode(ThemeMode mode) async {
    final p = await prefs;
    await p.setString(_keyThemeMode, mode.name);
  }

  Future<ThemeMode> getThemeMode() async {
    final p = await prefs;
    final value = p.getString(_keyThemeMode);
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  // Local
  Future<void> saveLocale(Locale locale) async {
    final p = await prefs;
    await p.setString(
      _keyLocaleCode,
      '${locale.languageCode}_${locale.countryCode}',
    );
  }

  Future<Locale?> getLocale() async {
    final p = await prefs;
    final value = p.getString(_keyLocaleCode);
    if (value == null) return null;

    final parts = value.split('_');
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    }
    return null;
  }

  // Privacy Policy
  Future<bool> isPrivacyPolicyAccepted() async {
    final p = await prefs;
    return p.getBool(_keyPrivacyPolicyAccepted) ?? false;
  }

  Future<void> setPrivacyPolicyAccepted() async {
    final p = await prefs;
    await p.setBool(_keyPrivacyPolicyAccepted, true);
  }

  // Security
  Future<bool> isSecurityConfigured() async {
    final p = await prefs;
    return p.getBool(_keySecurityConfigured) ?? false;
  }

  Future<void> setSecurityConfigured(bool value) async {
    final p = await prefs;
    await p.setBool(_keySecurityConfigured, value);
  }

  Future<SecurityType?> getSecurityType() async {
    final p = await prefs;
    final value = p.getString(_keySecurityType);
    if (value == null) return null;
    return SecurityTypeExtension.fromString(value);
  }

  Future<void> setSecurityType(SecurityType type) async {
    final p = await prefs;
    await p.setString(_keySecurityType, type.name);
  }

  Future<bool> isBiometricEnabled() async {
    final p = await prefs;
    return p.getBool(_keyBiometricEnabled) ?? false;
  }

  Future<void> setBiometricEnabled(bool value) async {
    final p = await prefs;
    await p.setBool(_keyBiometricEnabled, value);
  }
}
