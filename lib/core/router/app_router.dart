import 'package:go_router/go_router.dart';
import 'package:monefy_note_app/pages/home/page/home_page.dart';

final appRoutes = GoRouter(
  initialLocation: '/',

  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
  ],
);
