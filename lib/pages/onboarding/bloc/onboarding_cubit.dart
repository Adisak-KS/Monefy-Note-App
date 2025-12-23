import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monefy_note_app/core/services/preferences_service.dart';
import 'package:monefy_note_app/core/theme/theme_cubit.dart';
import 'package:monefy_note_app/pages/onboarding/bloc/onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final PreferencesService _prefsService;
  final ThemeCubit _themeCubit;

  OnboardingCubit({
    required PreferencesService prefsService,
    required ThemeCubit themeCubit,
    required Locale initialLocale,
  })  : _prefsService = prefsService,
        _themeCubit = themeCubit,
        super(OnboardingState.initial(initialLocale)) {
    // Load any saved progress from previous session
    _loadSavedProgress();
  }

  Future<void> _loadSavedProgress() async {
    final savedLocale = await _prefsService.getLocale();
    final savedTheme = await _prefsService.getThemeMode();

    if (savedLocale != null) {
      emit(state.copyWith(selectedLocale: savedLocale));
    }

    // Always load theme (defaults to system if not saved)
    _themeCubit.setTheme(savedTheme);
    emit(state.copyWith(selectedTheme: savedTheme));
  }

  void selectLocale(Locale locale) {
    emit(state.copyWith(selectedLocale: locale));
    // Save immediately so user's progress is preserved
    _prefsService.saveLocale(locale);
  }

  void selectTheme(ThemeMode theme) {
    _themeCubit.setTheme(theme);
    emit(state.copyWith(selectedTheme: theme));
    // Save immediately so user's progress is preserved
    _prefsService.saveThemeMode(theme);
  }

  Future<void> complete() async {
    // Preferences already saved, just mark onboarding complete
    await _prefsService.setFirstLaunchComplete();
  }
}
