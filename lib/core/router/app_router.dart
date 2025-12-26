import 'package:go_router/go_router.dart';
import 'package:monefy_note_app/pages/sign-in/page/sign_in_page.dart';
import 'package:monefy_note_app/pages/sign-up/page/sign_up_page.dart';
import 'package:monefy_note_app/pages/home/page/home_page.dart';
import 'package:monefy_note_app/pages/onboarding/page/onboarding_page.dart';
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
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),

    GoRoute(
      path: '/sign-in',
      name: 'sign-in',
      builder: (context, state) => const SignInPage(),
    ),

    GoRoute(
      path: '/sign-up',
      name: 'sign-up',
      builder: (context, state) => const SignUpPage(),
    ),

    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
  ],
);
