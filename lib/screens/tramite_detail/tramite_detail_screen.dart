import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:tramites_app/config/theme.dart';
import 'package:tramites_app/models/archivo_response.dart';
import 'package:tramites_app/models/tramite.dart';
import 'package:tramites_app/providers/conectividad_provider.dart';
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
      final provider = context.read<SolicitudesProvider>();
      provider.loadSolicitud(widget.id);
      provider.loadArchivos(widget.id);
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
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderSolicitud(solicitud: solicitud),
          if (solicitud.respuestasSolicitante.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            const _SeccionTitulo(
              icono: Icons.assignment_outlined,
              texto: 'Información enviada',
            ),
            const SizedBox(height: AppSpacing.sm),
            _SeccionRespuestas(respuestas: solicitud.respuestasSolicitante),
          ],
          // Documentos: arriba del seguimiento.
          _buildArchivos(provider),
          if (solicitud.respuestasPorDepartamento.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            const _SeccionTitulo(
              icono: Icons.timeline_outlined,
              texto: 'Seguimiento',
            ),
            const SizedBox(height: AppSpacing.md),
            _TimelineDepartamentos(
              departamentos: solicitud.respuestasPorDepartamento,
            ),
          ],
        ],
      ),
    );
  }

  /// Sección "Documentos" de la solicitud (módulo documental, con permisos).
  Widget _buildArchivos(SolicitudesProvider provider) {
    if (provider.isLoadingArchivos) {
      return const Padding(
        padding: EdgeInsets.only(top: 24),
        child: Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final archivos = provider.archivos;
    final offline = context.watch<ConectividadProvider>().offline;

    if (archivos.isEmpty) {
      // Offline → no mostramos error rojo (la lista puede no estar cacheada).
      // Solo mostramos un error real si estamos online y falló (ej: permiso).
      if (!offline && provider.errorArchivos != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            const _SeccionTitulo(
              icono: Icons.folder_outlined,
              texto: 'Documentos',
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              provider.errorArchivos!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        );
      }
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        const _SeccionTitulo(
          icono: Icons.folder_outlined,
          texto: 'Documentos',
        ),
        const SizedBox(height: AppSpacing.sm),
        ...archivos.map((a) => _ArchivoTile(
              archivo: a,
              onAbrir: () => _abrirArchivo(a),
            )),
      ],
    );
  }

  Future<void> _abrirArchivo(ArchivoResponse archivo) async {
    final provider = context.read<SolicitudesProvider>();
    final offline = context.read<ConectividadProvider>().offline;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Abriendo archivo…')),
    );
    try {
      // Descarga (la 1ª vez, con internet) y/o usa la copia local (offline).
      final ruta = await provider.prepararArchivoLocal(archivo);
      final resultado = await OpenFilex.open(ruta);
      if (resultado.type != ResultType.done && mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('No se pudo abrir: ${resultado.message}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      // Si está offline y el archivo no se descargó antes, mensaje amable.
      final msg = offline
          ? 'Necesitás internet para abrir este archivo por primera vez.'
          : e.toString().replaceFirst('Exception: ', '');
      messenger.showSnackBar(SnackBar(content: Text(msg)));
    }
  }
}

// ---------------------------------------------------------------------------
// Documentos (archivos de la solicitud)
// ---------------------------------------------------------------------------

class _ArchivoTile extends StatelessWidget {
  final ArchivoResponse archivo;
  final VoidCallback onAbrir;

  const _ArchivoTile({
    required this.archivo,
    required this.onAbrir,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final detalle = [
      if (archivo.campoFormularioOrigen != null &&
          archivo.campoFormularioOrigen!.isNotEmpty)
        archivo.campoFormularioOrigen!,
      if (archivo.tamanoLegible.isNotEmpty) archivo.tamanoLegible,
    ].join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(_iconoFormato(archivo.formato), color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    archivo.nombre,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (detalle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      detalle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              tooltip: 'Abrir',
              icon: const Icon(Icons.open_in_new),
              onPressed: onAbrir,
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconoFormato(String? formato) {
    switch (formato?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
      case 'gif':
        return Icons.image_outlined;
      case 'mp4':
      case 'mov':
        return Icons.videocam_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
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
// Título de sección reutilizable (icono + texto), coherente en toda la pantalla
// ---------------------------------------------------------------------------

class _SeccionTitulo extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _SeccionTitulo({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icono, size: 18, color: colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(texto, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Respuestas del solicitante
// ---------------------------------------------------------------------------

class _SeccionRespuestas extends StatelessWidget {
  final List<RespuestaSolicitante> respuestas;

  const _SeccionRespuestas({required this.respuestas});

  @override
  Widget build(BuildContext context) {
    return Card(
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
                      label: depto.accionEtiqueta ?? depto.accion ?? 'Respondido',
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
