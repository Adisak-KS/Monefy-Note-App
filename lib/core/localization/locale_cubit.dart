import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/preferences_service.dart';

class LocalCubit extends Cubit<Locale> {
  final PreferencesService _preferencesService;

  LocalCubit({PreferencesService? preferencesService})
      : _preferencesService = preferencesService ?? PreferencesService(),
        super(const Locale('th', 'TH'));

  Future<void> init() async {
    final savedLocale = await _preferencesService.getLocale();
    if (savedLocale != null) {
      emit(savedLocale);
    }
  }

  Future<void> setThai() async {
    const locale = Locale('th', 'TH');
    await _preferencesService.saveLocale(locale);
    emit(locale);
  }

  Future<void> setEnglish() async {
    const locale = Locale('en', 'US');
    await _preferencesService.saveLocale(locale);
    emit(locale);
  }

  Future<void> setLocal(Locale locale) async {
    await _preferencesService.saveLocale(locale);
    emit(locale);
  }
}
