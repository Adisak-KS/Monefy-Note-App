import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:monefy_note_app/pages/sign-in/page/sign_in_page.dart';
import 'package:monefy_note_app/pages/sign-up/page/sign_up_page.dart';
import 'package:monefy_note_app/pages/privacy-policy/page/privacy_policy_page.dart';
import 'package:monefy_note_app/pages/main_shell.dart';
import 'package:monefy_note_app/pages/onboarding/page/onboarding_page.dart';
import 'package:monefy_note_app/pages/splash/page/splash_page.dart';
import 'package:monefy_note_app/pages/security-setup/page/security_setup_page.dart';
import 'package:monefy_note_app/pages/security-verify/page/security_verify_page.dart';
import 'package:monefy_note_app/pages/add-transaction/page/add_transaction_page.dart';
import 'package:monefy_note_app/pages/home/bloc/home_cubit.dart';
import 'package:monefy_note_app/pages/categories/page/categories_page.dart';
import 'package:monefy_note_app/pages/budgets/page/budgets_page.dart';
import 'package:monefy_note_app/pages/settings/page/settings_page.dart';
import 'package:monefy_note_app/pages/export/page/export_page.dart';
import 'page_transitions.dart';

final appRoutes = GoRouter(
  // initialLocation: '/splash',
  initialLocation: '/home',

  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      pageBuilder: (context, state) => AppPageTransitions.fade(
        key: state.pageKey,
        child: const SplashPage(),
      ),
    ),

    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      pageBuilder: (context, state) => AppPageTransitions.fade(
        key: state.pageKey,
        child: const OnboardingPage(),
      ),
    ),

    GoRoute(
      path: '/sign-in',
      name: 'sign-in',
      pageBuilder: (context, state) => AppPageTransitions.slideUp(
        key: state.pageKey,
        child: const SignInPage(),
      ),
    ),

    GoRoute(
      path: '/sign-up',
      name: 'sign-up',
      pageBuilder: (context, state) => AppPageTransitions.slideUp(
        key: state.pageKey,
        child: const SignUpPage(),
      ),
    ),

    GoRoute(
      path: '/privacy-policy',
      name: 'privacy-policy',
      pageBuilder: (context, state) => AppPageTransitions.slideFromRight(
        key: state.pageKey,
        child: const PrivacyPolicyPage(),
      ),
    ),

    GoRoute(
      path: '/security-setup',
      name: 'security-setup',
      pageBuilder: (context, state) => AppPageTransitions.slideFromRight(
        key: state.pageKey,
        child: const SecuritySetupPage(),
      ),
    ),

    GoRoute(
      path: '/security-verify',
      name: 'security-verify',
      pageBuilder: (context, state) => AppPageTransitions.fade(
        key: state.pageKey,
        child: const SecurityVerifyPage(),
      ),
    ),

    GoRoute(
      path: '/home',
      name: 'home',
      pageBuilder: (context, state) => AppPageTransitions.fade(
        key: state.pageKey,
        child: const MainShell(),
      ),
    ),

    GoRoute(
      path: '/add-transaction',
      name: 'add-transaction',
      pageBuilder: (context, state) {
        final homeCubit = state.extra as HomeCubit?;
        return AppPageTransitions.slideUp(
          key: state.pageKey,
          child: BlocProvider.value(
            value: homeCubit!,
            child: const AddTransactionPage(),
          ),
        );
      },
    ),

    GoRoute(
      path: '/categories',
      name: 'categories',
      pageBuilder: (context, state) => AppPageTransitions.slideFromRight(
        key: state.pageKey,
        child: const CategoriesPage(),
      ),
    ),

    GoRoute(
      path: '/budgets',
      name: 'budgets',
      pageBuilder: (context, state) => AppPageTransitions.slideFromRight(
        key: state.pageKey,
        child: const BudgetsPage(),
      ),
    ),

    GoRoute(
      path: '/settings',
      name: 'settings',
      pageBuilder: (context, state) => AppPageTransitions.slideFromRight(
        key: state.pageKey,
        child: const SettingsPage(),
      ),
    ),

    GoRoute(
      path: '/export',
      name: 'export',
      pageBuilder: (context, state) => AppPageTransitions.slideFromRight(
        key: state.pageKey,
        child: const ExportPage(),
      ),
    ),
  ],
);
