import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tramites_app/config/theme.dart';
import 'package:tramites_app/models/solicitud_item.dart';
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
              Icon(Icons.error_outline,
                  size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: AppSpacing.md),
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
      final cs = Theme.of(context).colorScheme;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_outlined,
                size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Todavía no tenés solicitudes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Cuando inicies un trámite, aparecerá acá.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
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
            _SolicitudCard(item: provider.solicitudes[index]),
      ),
    );
  }
}

/// Acción elegida en el diálogo de una solicitud fallida.
enum _AccionError { cerrar, reintentar, descartar }

class _SolicitudCard extends StatelessWidget {
  final SolicitudItem item;

  const _SolicitudCard({required this.item});

  void _abrir(BuildContext context) {
    if (item.esError) {
      _mostrarError(context);
      return;
    }
    if (item.pendienteSync) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Pendiente de envío — se enviará automáticamente al sincronizar.'),
        ),
      );
      return;
    }
    context.push('/solicitudes/${item.resumen.id}');
  }

  Future<void> _mostrarError(BuildContext context) async {
    final accion = await showDialog<_AccionError>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('No se pudo enviar'),
        content: Text(
          item.syncError ?? 'Ocurrió un error al enviar la solicitud.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, _AccionError.descartar),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Descartar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, _AccionError.cerrar),
            child: const Text('Cerrar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, _AccionError.reintentar),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    final provider = context.read<SolicitudesProvider>();
    final messenger = ScaffoldMessenger.of(context);

    if (accion == _AccionError.reintentar) {
      provider.reintentarSolicitud(item.resumen.id);
      messenger.showSnackBar(
        const SnackBar(content: Text('Reintentando envío…')),
      );
    } else if (accion == _AccionError.descartar) {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Descartar solicitud'),
          content: const Text(
            'Esta solicitud no se envió y se borrará de tu dispositivo. '
            '¿Querés descartarla?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error,
              ),
              child: const Text('Descartar'),
            ),
          ],
        ),
      );
      if (confirmar == true && context.mounted) {
        await context
            .read<SolicitudesProvider>()
            .descartarSolicitud(item.resumen.id);
        messenger.showSnackBar(
          const SnackBar(content: Text('Solicitud descartada.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final solicitud = item.resumen;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => _abrir(context),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Icono guía (le da "vida" a la lista, no solo texto).
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            solicitud.tramiteNombre ?? 'Trámite',
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        if (item.esError)
                          const _ChipEstado(
                            texto: 'Error',
                            icono: Icons.error_outline,
                            color: Colors.red,
                          )
                        else if (item.pendienteSync)
                          const _ChipEstado(
                            texto: 'Pendiente',
                            icono: Icons.cloud_upload_outlined,
                            color: Colors.orange,
                          )
                        else
                          StatusBadge(estado: solicitud.estado),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 14, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          _formatearFecha(solicitud.fechaCreacion),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip de estado de sincronización (Pendiente / Error) para solicitudes locales.
class _ChipEstado extends StatelessWidget {
  final String texto;
  final IconData icono;
  final MaterialColor color;

  const _ChipEstado({
    required this.texto,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: color.shade900),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              color: color.shade900,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
