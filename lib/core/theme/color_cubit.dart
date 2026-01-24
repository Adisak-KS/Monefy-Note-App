import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/preferences_service.dart';
import 'app_color.dart';

class ColorCubit extends Cubit<AppColor> {
  final PreferencesService _preferencesService;

  ColorCubit({PreferencesService? preferencesService})
      : _preferencesService = preferencesService ?? PreferencesService(),
        super(AppColor.presets.first);

  Future<void> init() async {
    final savedColor = await _preferencesService.getAppColor();
    emit(savedColor);
  }

  Future<void> setColor(AppColor color) async {
    await _preferencesService.saveAppColor(color);
    emit(color);
  }

  Future<void> setColorByTheme(AppColorTheme theme) async {
    final color = AppColor.fromTheme(theme);
    await setColor(color);
  }
}
