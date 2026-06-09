import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tramites_app/providers/auth_provider.dart';

/// Pantalla de perfil: datos del usuario logueado + cerrar sesión.
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    final nombre = (auth.nombre ?? '').trim();
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: colorScheme.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 8),
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                inicial,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              nombre.isNotEmpty ? nombre : 'Usuario',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          if (auth.rol != null && auth.rol!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Center(
              child: Chip(
                label: Text(_prettyRol(auth.rol!)),
                backgroundColor: colorScheme.secondaryContainer,
                labelStyle:
                    TextStyle(color: colorScheme.onSecondaryContainer),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                _InfoTile(
                  icono: Icons.email_outlined,
                  etiqueta: 'Correo',
                  valor: auth.email ?? '—',
                ),
                if (auth.rol != null && auth.rol!.isNotEmpty)
                  _InfoTile(
                    icono: Icons.badge_outlined,
                    etiqueta: 'Rol',
                    valor: _prettyRol(auth.rol!),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () => _confirmarLogout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _prettyRol(String rol) {
    final limpio = rol.replaceAll('_', ' ').toLowerCase();
    if (limpio.isEmpty) return rol;
    return limpio[0].toUpperCase() + limpio.substring(1);
  }

  Future<void> _confirmarLogout(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que querés cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    // logout() limpia el token y notifica → el router redirige a /login solo.
    if (confirmar == true && context.mounted) {
      context.read<AuthProvider>().logout();
    }
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;

  const _InfoTile({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icono, color: colorScheme.primary),
      title: Text(
        etiqueta,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
      ),
      subtitle: Text(
        valor,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
