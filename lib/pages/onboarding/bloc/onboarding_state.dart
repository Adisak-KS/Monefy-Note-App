import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class OnboardingState extends Equatable {
  final Locale selectedLocale;
  final ThemeMode selectedTheme;

  const OnboardingState({
    required this.selectedLocale,
    required this.selectedTheme,
  });

  factory OnboardingState.initial(Locale systemLocale) {
    return OnboardingState(
      selectedLocale: systemLocale,
      selectedTheme: ThemeMode.system,
    );
  }

  OnboardingState copyWith({Locale? selectedLocale, ThemeMode? selectedTheme}) {
    return OnboardingState(
      selectedLocale: selectedLocale ?? this.selectedLocale,
      selectedTheme: selectedTheme ?? this.selectedTheme,
    );
  }

  @override
  List<Object?> get props => [selectedLocale, selectedTheme];
}
