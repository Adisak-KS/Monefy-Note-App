import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monefy_note_app/core/cubit/network_cubit.dart';
import 'package:monefy_note_app/core/router/app_router.dart';
import 'package:monefy_note_app/core/services/network_service.dart';
import 'package:monefy_note_app/core/theme/app_theme.dart' show AppTheme;
import 'package:monefy_note_app/core/theme/theme_cubit.dart';
import 'package:monefy_note_app/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await NetworkService.instance.initialize();
  configureDependencies();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('th', 'TH'), Locale('en', 'US')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => NetworkCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return ScreenUtilInit(
            designSize: const Size(375, 812), // iPhone X Size
            minTextAdapt: true,
            builder: (_, child) {
              return MaterialApp.router(
                title: 'Monefy Note',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: themeMode,
                routerConfig: appRoutes,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
              );
            },
          );
        },
      ),
    );
  }
}
