import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monefy_note_app/core/bloc/drawer_stats_cubit.dart';
import 'package:monefy_note_app/core/cubit/network_cubit.dart';
import 'package:monefy_note_app/core/localization/locale_cubit.dart';
import 'package:monefy_note_app/core/router/app_router.dart';
import 'package:monefy_note_app/core/services/network_service.dart';
import 'package:monefy_note_app/core/services/preferences_service.dart';
import 'package:monefy_note_app/core/theme/app_color.dart';
import 'package:monefy_note_app/core/theme/app_theme.dart' show AppTheme;
import 'package:monefy_note_app/core/theme/color_cubit.dart';
import 'package:monefy_note_app/core/theme/theme_cubit.dart';
import 'package:monefy_note_app/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await NetworkService.instance.initialize();
  configureDependencies();

  // Initialize preferences service
  final preferencesService = PreferencesService();

  // Create and initialize cubits
  final themeCubit = ThemeCubit(preferencesService: preferencesService);
  final localeCubit = LocalCubit(preferencesService: preferencesService);
  final colorCubit = ColorCubit(preferencesService: preferencesService);

  // Load saved preferences
  await themeCubit.init();
  await localeCubit.init();
  await colorCubit.init();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('th', 'TH'), Locale('en', 'US')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      startLocale: localeCubit.state,
      child: MyApp(
        themeCubit: themeCubit,
        localeCubit: localeCubit,
        colorCubit: colorCubit,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ThemeCubit themeCubit;
  final LocalCubit localeCubit;
  final ColorCubit colorCubit;

  const MyApp({
    super.key,
    required this.themeCubit,
    required this.localeCubit,
    required this.colorCubit,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: themeCubit),
        BlocProvider.value(value: localeCubit),
        BlocProvider.value(value: colorCubit),
        BlocProvider(create: (_) => NetworkCubit()),
        BlocProvider(create: (_) => getIt<DrawerStatsCubit>()),
      ],
      child: BlocBuilder<ColorCubit, AppColor>(
        builder: (context, appColor) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return ScreenUtilInit(
                designSize: const Size(375, 812), // iPhone X Size
                minTextAdapt: true,
                builder: (_, child) {
                  return MaterialApp.router(
                    title: 'Monefy Note',
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.light(appColor),
                    darkTheme: AppTheme.dark(appColor),
                    themeMode: themeMode,
                    routerConfig: appRoutes,
                    localizationsDelegates: context.localizationDelegates,
                    supportedLocales: context.supportedLocales,
                    locale: context.locale,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
