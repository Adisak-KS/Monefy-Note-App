import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/currency.dart';
import '../services/preferences_service.dart';

class CurrencyCubit extends Cubit<Currency> {
  final PreferencesService _preferencesService;

  CurrencyCubit({PreferencesService? preferencesService})
      : _preferencesService = preferencesService ?? PreferencesService(),
        super(Currency.thb);

  Future<void> init() async {
    final savedCurrencyCode = await _preferencesService.getDefaultCurrency();
    final currency = Currency.fromCode(savedCurrencyCode);
    emit(currency);
  }

  Future<void> setCurrency(Currency currency) async {
    await _preferencesService.saveDefaultCurrency(currency.code);
    emit(currency);
  }
}
