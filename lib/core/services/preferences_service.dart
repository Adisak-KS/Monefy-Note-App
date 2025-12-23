import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _keyFirstLaunch = 'first_launch_complete';
  static const _keyThemeMode = 'theme_mode';
  static const _keyLocaleCode = 'locale_code';

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
}
