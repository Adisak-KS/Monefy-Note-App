import 'package:go_router/go_router.dart';
import 'package:monefy_note_app/pages/home/page/home_page.dart';
import 'package:monefy_note_app/pages/splash/page/splash_page.dart';

final appRoutes = GoRouter(
  initialLocation: '/splash',

  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),

    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
  ],
);
