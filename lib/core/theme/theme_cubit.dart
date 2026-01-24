import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/preferences_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final PreferencesService _preferencesService;

  ThemeCubit({PreferencesService? preferencesService})
      : _preferencesService = preferencesService ?? PreferencesService(),
        super(ThemeMode.system);

  Future<void> init() async {
    final savedTheme = await _preferencesService.getThemeMode();
    emit(savedTheme);
  }

  Future<void> setLight() async {
    await _preferencesService.saveThemeMode(ThemeMode.light);
    emit(ThemeMode.light);
  }

  Future<void> setDark() async {
    await _preferencesService.saveThemeMode(ThemeMode.dark);
    emit(ThemeMode.dark);
  }

  Future<void> setSystem() async {
    await _preferencesService.saveThemeMode(ThemeMode.system);
    emit(ThemeMode.system);
  }

  Future<void> setTheme(ThemeMode mode) async {
    await _preferencesService.saveThemeMode(mode);
    emit(mode);
  }

  Future<void> toggle() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _preferencesService.saveThemeMode(newMode);
    emit(newMode);
  }
}
