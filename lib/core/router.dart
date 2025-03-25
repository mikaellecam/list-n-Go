import 'package:go_router/go_router.dart';

import '../views/screens/home_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/home',
  routes: [GoRoute(path: '/home', builder: (context, state) => HomeScreen())],
);
