import 'package:go_router/go_router.dart';

import '../screens/bus_tracker_screen/bus_tracker_screen.dart';
import '../screens/bus_tracking_screen/bus_tracking_screen.dart';
import '../screens/login_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'linhas',
        builder: (context, state) => const BusTrackerScreen(),
      ),
      GoRoute(
        path: '/localizar',
        name: 'rastreamento',
        builder: (context, state) => BusTrackingScreen(
          linhaData: state.extra is Map<String, dynamic>
              ? state.extra! as Map<String, dynamic>
              : const {},
        ),
      ),
    ],
  );
}
