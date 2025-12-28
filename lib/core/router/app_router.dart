import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:monefy_note_app/pages/sign-in/page/sign_in_page.dart';
import 'package:monefy_note_app/pages/sign-up/page/sign_up_page.dart';
import 'package:monefy_note_app/pages/privacy-policy/page/privacy_policy_page.dart';
import 'package:monefy_note_app/pages/main/main_shell.dart';
import 'package:monefy_note_app/pages/onboarding/page/onboarding_page.dart';
import 'package:monefy_note_app/pages/splash/page/splash_page.dart';
import 'package:monefy_note_app/pages/security-setup/page/security_setup_page.dart';
import 'package:monefy_note_app/pages/security-verify/page/security_verify_page.dart';
import 'package:monefy_note_app/pages/add-transaction/page/add_transaction_page.dart';
import 'package:monefy_note_app/pages/home/bloc/home_cubit.dart';

final appRoutes = GoRouter(
  // initialLocation: '/splash',
  initialLocation: '/home',

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
      path: '/privacy-policy',
      name: 'privacy-policy',
      builder: (context, state) => const PrivacyPolicyPage(),
    ),

    GoRoute(
      path: '/security-setup',
      name: 'security-setup',
      builder: (context, state) => const SecuritySetupPage(),
    ),

    GoRoute(
      path: '/security-verify',
      name: 'security-verify',
      builder: (context, state) => const SecurityVerifyPage(),
    ),

    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const MainShell(),
    ),

    GoRoute(
      path: '/add-transaction',
      name: 'add-transaction',
      builder: (context, state) {
        final homeCubit = state.extra as HomeCubit?;
        return BlocProvider.value(
          value: homeCubit!,
          child: const AddTransactionPage(),
        );
      },
    ),
  ],
);
