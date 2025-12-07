import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocalCubit extends Cubit<Locale> {
  LocalCubit() : super(const Locale('th', 'TH'));

  void setThai() => emit(const Locale('th', 'TH'));
  void setEnglish() => emit(const Locale('en', 'US'));
  void setLocal(Locale local) => emit(local);
}
