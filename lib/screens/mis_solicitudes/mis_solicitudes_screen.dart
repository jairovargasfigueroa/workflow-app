import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tramites_app/models/tramite.dart';
import 'package:tramites_app/providers/solicitudes_provider.dart';
import 'package:tramites_app/widgets/status_badge.dart';

class MisSolicitudesScreen extends StatefulWidget {
  const MisSolicitudesScreen({super.key});

  @override
  State<MisSolicitudesScreen> createState() => _MisSolicitudesScreenState();
}

class _MisSolicitudesScreenState extends State<MisSolicitudesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SolicitudesProvider>().loadMisSolicitudes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SolicitudesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis solicitudes'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: _buildCuerpo(provider),
    );
  }

  Widget _buildCuerpo(SolicitudesProvider provider) {
    if (provider.isLoadingLista) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorLista != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                provider.errorLista!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () =>
                    context.read<SolicitudesProvider>().loadMisSolicitudes(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.solicitudes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tienes solicitudes',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          context.read<SolicitudesProvider>().loadMisSolicitudes(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        itemCount: provider.solicitudes.length,
        itemBuilder: (context, index) =>
            _SolicitudCard(solicitud: provider.solicitudes[index]),
      ),
    );
  }
}

class _SolicitudCard extends StatelessWidget {
  final SolicitudResumen solicitud;

  const _SolicitudCard({required this.solicitud});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/solicitudes/${solicitud.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      solicitud.tramiteNombre ?? 'Trámite',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(estado: solicitud.estado),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 14, color: colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    _formatearFecha(solicitud.fechaCreacion),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatearFecha(DateTime fecha) {
  final dia = fecha.day.toString().padLeft(2, '0');
  const meses = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];
  return '$dia de ${meses[fecha.month - 1]} de ${fecha.year}';
}
