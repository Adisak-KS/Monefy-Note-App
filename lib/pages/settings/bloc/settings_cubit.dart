import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/services/preferences_service.dart';
import 'settings_state.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  final PreferencesService _preferencesService;

  SettingsCubit(this._preferencesService) : super(const SettingsInitial());

  Future<void> loadSettings() async {
    emit(const SettingsLoading());

    try {
      final themeMode = await _preferencesService.getThemeMode();
      final locale = await _preferencesService.getLocale() ?? const Locale('th', 'TH');
      final isSecurityEnabled = await _preferencesService.isSecurityConfigured();
      final securityType = await _preferencesService.getSecurityType();
      final isBiometricEnabled = await _preferencesService.isBiometricEnabled();

      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';

      emit(SettingsLoaded(
        themeMode: themeMode,
        locale: locale,
        isSecurityEnabled: isSecurityEnabled,
        securityType: securityType,
        isBiometricEnabled: isBiometricEnabled,
        appVersion: appVersion,
      ));
    } catch (error) {
      emit(SettingsError(error.toString()));
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state is! SettingsLoaded) return;
    final currentState = state as SettingsLoaded;

    await _preferencesService.saveThemeMode(mode);
    emit(currentState.copyWith(themeMode: mode));
  }

  Future<void> setLocale(Locale locale) async {
    if (state is! SettingsLoaded) return;
    final currentState = state as SettingsLoaded;

    await _preferencesService.saveLocale(locale);
    emit(currentState.copyWith(locale: locale));
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    if (state is! SettingsLoaded) return;
    final currentState = state as SettingsLoaded;

    await _preferencesService.setBiometricEnabled(enabled);
    emit(currentState.copyWith(isBiometricEnabled: enabled));
  }

  Future<void> refreshSecurityStatus() async {
    if (state is! SettingsLoaded) return;
    final currentState = state as SettingsLoaded;

    final isSecurityEnabled = await _preferencesService.isSecurityConfigured();
    final securityType = await _preferencesService.getSecurityType();
    final isBiometricEnabled = await _preferencesService.isBiometricEnabled();

    emit(currentState.copyWith(
      isSecurityEnabled: isSecurityEnabled,
      securityType: securityType,
      isBiometricEnabled: isBiometricEnabled,
    ));
  }
}
