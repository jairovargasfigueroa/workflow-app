import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tramites_app/models/tramite.dart';
import 'package:tramites_app/providers/solicitudes_provider.dart';
import 'package:tramites_app/widgets/status_badge.dart';

class TramiteDetailScreen extends StatefulWidget {
  final String id;

  const TramiteDetailScreen({super.key, required this.id});

  @override
  State<TramiteDetailScreen> createState() => _TramiteDetailScreenState();
}

class _TramiteDetailScreenState extends State<TramiteDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SolicitudesProvider>().loadSolicitud(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SolicitudesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: _buildCuerpo(provider),
    );
  }

  Widget _buildCuerpo(SolicitudesProvider provider) {
    if (provider.isLoadingDetalle) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorDetalle != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                provider.errorDetalle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context
                    .read<SolicitudesProvider>()
                    .loadSolicitud(widget.id),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final solicitud = provider.solicitudSeleccionada;
    if (solicitud == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderSolicitud(solicitud: solicitud),
          if (solicitud.respuestasSolicitante.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SeccionRespuestas(
              titulo: 'Información enviada',
              respuestas: solicitud.respuestasSolicitante,
            ),
          ],
          if (solicitud.respuestasPorDepartamento.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Seguimiento',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _TimelineDepartamentos(
              departamentos: solicitud.respuestasPorDepartamento,
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _HeaderSolicitud extends StatelessWidget {
  final SolicitudDetalle solicitud;

  const _HeaderSolicitud({required this.solicitud});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              solicitud.tramiteNombre ?? 'Trámite',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            StatusBadge(estado: solicitud.estado),
            const SizedBox(height: 16),
            _InfoFila(
              icono: Icons.calendar_today,
              etiqueta: 'Fecha de creación',
              valor: _formatearFechaCompleta(solicitud.fechaCreacion),
              colorScheme: colorScheme,
            ),
            if (solicitud.fechaFinalizacion != null) ...[
              const SizedBox(height: 8),
              _InfoFila(
                icono: Icons.check_circle_outline,
                etiqueta: 'Fecha de finalización',
                valor: _formatearFechaCompleta(solicitud.fechaFinalizacion!),
                colorScheme: colorScheme,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoFila extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;
  final ColorScheme colorScheme;

  const _InfoFila({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 16, color: colorScheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etiqueta,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(valor, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Respuestas del solicitante
// ---------------------------------------------------------------------------

class _SeccionRespuestas extends StatelessWidget {
  final String titulo;
  final List<RespuestaSolicitante> respuestas;

  const _SeccionRespuestas({
    required this.titulo,
    required this.respuestas,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: respuestas.map((r) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          r.nombreCampo ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: Text(
                          r.valor ?? '-',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Timeline de departamentos
// ---------------------------------------------------------------------------

class _TimelineDepartamentos extends StatelessWidget {
  final List<RespuestaDepartamento> departamentos;

  const _TimelineDepartamentos({required this.departamentos});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(departamentos.length, (index) {
        return _TimelineItem(
          depto: departamentos[index],
          esUltimo: index == departamentos.length - 1,
        );
      }),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final RespuestaDepartamento depto;
  final bool esUltimo;

  const _TimelineItem({required this.depto, required this.esUltimo});

  bool get _respondio => depto.fechaRespuesta != null;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dotColor = _respondio ? colorScheme.primary : colorScheme.outline;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: dotColor.withValues(alpha: 0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                if (!esUltimo)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: esUltimo ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    depto.departamentoNombre ?? 'Departamento',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  if (!_respondio)
                    _Chip(
                      label: 'En proceso',
                      color: colorScheme.secondaryContainer,
                      textColor: colorScheme.onSecondaryContainer,
                    )
                  else ...[
                    _Chip(
                      label: depto.accion ?? 'Respondido',
                      color: colorScheme.primaryContainer,
                      textColor: colorScheme.onPrimaryContainer,
                    ),
                    if (depto.fechaRespuesta != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatearFechaCompleta(depto.fechaRespuesta!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                    if (depto.comentario != null &&
                        depto.comentario!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          depto.comentario!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _Chip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _formatearFechaCompleta(DateTime fecha) {
  final dia = fecha.day.toString().padLeft(2, '0');
  const meses = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];
  final hora = fecha.hour.toString().padLeft(2, '0');
  final minuto = fecha.minute.toString().padLeft(2, '0');
  return '$dia de ${meses[fecha.month - 1]} de ${fecha.year}, $hora:$minuto';
}
