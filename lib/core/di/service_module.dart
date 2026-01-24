import 'package:injectable/injectable.dart';
import '../services/preferences_service.dart';

@module
abstract class ServiceModule {
  @lazySingleton
  PreferencesService get preferencesService => PreferencesService();
}
