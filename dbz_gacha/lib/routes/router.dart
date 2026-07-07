import 'package:go_router/go_router.dart';

import '../screens/home.dart';
import '../screens/catalogue.dart';
import '../screens/invocation.dart';
import '../screens/info.dart';
import '../widgets/main_scaffold.dart';
import '../models/perso.dart';

final GoRouter router = GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => Home(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/catalogue',
              builder: (context, state) => Catalogue(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/invocation',
              builder: (context, state) => Invocation(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/info_personnage',
      builder: (context, state) => Personnage(perso: state.extra as Perso),
    ),
  ],
);