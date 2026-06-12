import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tramites_app/config/theme.dart';
import 'package:tramites_app/models/tramite.dart';
import 'package:tramites_app/providers/tramites_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TramitesProvider>().loadTramites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TramitesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trámites disponibles'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: _buildCuerpo(provider),
    );
  }

  Widget _buildCuerpo(TramitesProvider provider) {
    if (provider.isLoadingTramites) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: AppSpacing.md),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () =>
                    context.read<TramitesProvider>().loadTramites(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.tramites.isEmpty) {
      final cs = Theme.of(context).colorScheme;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined,
                size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No hay trámites disponibles',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<TramitesProvider>().loadTramites(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        itemCount: provider.tramites.length,
        itemBuilder: (context, index) =>
            _TramiteDisponibleCard(tramite: provider.tramites[index]),
      ),
    );
  }
}

class _TramiteDisponibleCard extends StatelessWidget {
  final TramiteDisponible tramite;

  const _TramiteDisponibleCard({required this.tramite});

  void _navegar(BuildContext context) {
    if (tramite.formularioSolicitanteId == null) return;
    final nombre = Uri.encodeComponent(tramite.nombre);
    final formularioId = Uri.encodeComponent(tramite.formularioSolicitanteId!);
    context.push(
      '/tramites/${tramite.id}/formulario?formularioId=$formularioId&nombre=$nombre',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => _navegar(context),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      Icons.assignment_outlined,
                      size: 22,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        tramite.nombre,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                ],
              ),
              if (tramite.descripcion != null &&
                  tramite.descripcion!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  tramite.descripcion!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
              if (tramite.requisitos.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Requisitos',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                ...tramite.requisitos.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Icon(
                            Icons.circle,
                            size: 5,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            r,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonal(
                  onPressed: tramite.formularioSolicitanteId == null
                      ? null
                      : () => _navegar(context),
                  child: const Text('Iniciar solicitud'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
