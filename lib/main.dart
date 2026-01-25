import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monefy_note_app/core/bloc/drawer_stats_cubit.dart';
import 'package:monefy_note_app/core/cubit/currency_cubit.dart';
import 'package:monefy_note_app/core/cubit/network_cubit.dart';
import 'package:monefy_note_app/core/localization/locale_cubit.dart';
import 'package:monefy_note_app/core/router/app_router.dart';
import 'package:monefy_note_app/core/services/network_service.dart';
import 'package:monefy_note_app/core/services/preferences_service.dart';
import 'package:monefy_note_app/core/theme/app_color.dart';
import 'package:monefy_note_app/core/theme/app_theme.dart' show AppTheme;
import 'package:monefy_note_app/core/theme/color_cubit.dart';
import 'package:monefy_note_app/core/theme/theme_cubit.dart';
import 'package:monefy_note_app/core/widgets/error_boundary.dart';
import 'package:monefy_note_app/core/widgets/network_status_banner.dart';
import 'package:monefy_note_app/core/di/repository_module.dart';
import 'package:monefy_note_app/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await NetworkService.instance.initialize();
  await initializeRepositories();
  configureDependencies();

  // Allow Google Fonts to work offline (use cached/bundled fonts)
  GoogleFonts.config.allowRuntimeFetching = false;

  // Set up global error handling for Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint('FlutterError: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');
    }
  };

  // Handle errors that aren't caught by the Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('PlatformDispatcher error: $error');
      debugPrint('Stack trace: $stack');
    }
    return true;
  };

  // Initialize preferences service
  final preferencesService = PreferencesService();

  // Create and initialize cubits
  final themeCubit = ThemeCubit(preferencesService: preferencesService);
  final localeCubit = LocalCubit(preferencesService: preferencesService);
  final colorCubit = ColorCubit(preferencesService: preferencesService);
  final currencyCubit = CurrencyCubit(preferencesService: preferencesService);

  // Load saved preferences
  await themeCubit.init();
  await localeCubit.init();
  await colorCubit.init();
  await currencyCubit.init();

  runApp(
    ErrorBoundary(
      onError: (error, stack) {
        if (kDebugMode) {
          debugPrint('ErrorBoundary caught: $error');
        }
      },
      child: EasyLocalization(
        supportedLocales: const [Locale('th', 'TH'), Locale('en', 'US')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en', 'US'),
        startLocale: localeCubit.state,
        child: MyApp(
          themeCubit: themeCubit,
          localeCubit: localeCubit,
          colorCubit: colorCubit,
          currencyCubit: currencyCubit,
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ThemeCubit themeCubit;
  final LocalCubit localeCubit;
  final ColorCubit colorCubit;
  final CurrencyCubit currencyCubit;

  const MyApp({
    super.key,
    required this.themeCubit,
    required this.localeCubit,
    required this.colorCubit,
    required this.currencyCubit,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: themeCubit),
        BlocProvider.value(value: localeCubit),
        BlocProvider.value(value: colorCubit),
        BlocProvider.value(value: currencyCubit),
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
                    builder: (context, child) {
                      return GestureDetector(
                        onTap: () => FocusScope.of(context).unfocus(),
                        child: NetworkStatusBanner(
                          child: child ?? const SizedBox.shrink(),
                        ),
                      );
                    },
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
