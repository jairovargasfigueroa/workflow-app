import 'package:tramites_app/models/tramite.dart';

/// Ítem de la lista de solicitudes: el resumen + estado de sincronización.
class SolicitudItem {
  final SolicitudResumen resumen;

  /// Creada offline, aún no enviada al backend.
  final bool pendienteSync;

  /// Motivo del fallo de envío (null = sin error).
  final String? syncError;

  const SolicitudItem({
    required this.resumen,
    required this.pendienteSync,
    this.syncError,
  });

  /// Falló el envío (permanente / agotó reintentos) → estado "Error".
  bool get esError => syncError != null;
}
