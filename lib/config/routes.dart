import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tramites_app/providers/auth_provider.dart';
import 'package:tramites_app/screens/agente_tramites/chat_agente_screen.dart';
import 'package:tramites_app/screens/home/home_screen.dart';
import 'package:tramites_app/screens/login/login_screen.dart';
import 'package:tramites_app/screens/mis_solicitudes/mis_solicitudes_screen.dart';
import 'package:tramites_app/screens/perfil/perfil_screen.dart';
import 'package:tramites_app/screens/solicitud_form/solicitud_form_screen.dart';
import 'package:tramites_app/screens/tramite_detail/tramite_detail_screen.dart';

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final loggedIn = authProvider.isLoggedIn;
      final isLogin = state.matchedLocation == '/login';
      if (!loggedIn && !isLogin) return '/login';
      if (loggedIn && isLogin) return '/tramites';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _ShellScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tramites',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: ':id/formulario',
                    builder: (context, state) {
                      final tramiteId = state.pathParameters['id']!;
                      final params = state.uri.queryParameters;
                      return SolicitudFormScreen(
                        tramiteId: tramiteId,
                        formularioSolicitanteId: params['formularioId'] ?? '',
                        tramiteNombre: params['nombre'] ?? '',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/agente',
                builder: (context, state) => const ChatAgenteScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/solicitudes',
                builder: (context, state) => const MisSolicitudesScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => TramiteDetailScreen(
                      id: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/perfil',
                builder: (context, state) => const PerfilScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _ShellScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _ShellScaffold({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description),
            label: 'Trámites',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy),
            label: 'Asistente',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Mis solicitudes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
