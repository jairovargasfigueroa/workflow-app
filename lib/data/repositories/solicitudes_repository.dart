import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:tramites_app/data/local/app_database.dart';
import 'package:tramites_app/models/solicitud_item.dart';
import 'package:tramites_app/models/tramite.dart';

/// Lee/escribe solicitudes en Drift (fuente de verdad local).
/// La UI lee de acá; el SyncManager es el que llena Drift desde la API.
class SolicitudesRepository {
  final AppDatabase _db;

  SolicitudesRepository(this._db);

  /// Stream reactivo de la lista (la UI se actualiza sola cuando cambia Drift).
  /// Cada ítem trae el resumen + si está pendiente de sincronizar.
  Stream<List<SolicitudItem>> watchSolicitudes() {
    final query = _db.select(_db.solicitudes)
      ..orderBy([(t) => OrderingTerm.desc(t.fechaCreacion)]);
    return query.watch().map(
          (rows) => rows
              .map((r) => SolicitudItem(
                    resumen: _aResumen(r),
                    pendienteSync: r.pendienteSync,
                    syncError: r.syncError,
                  ))
              .toList(),
        );
  }

  /// Marca la solicitud local como fallida (estado "Error" en la lista).
  Future<void> marcarErrorSync(String clientId, String error) async {
    await (_db.update(_db.solicitudes)..where((t) => t.id.equals(clientId)))
        .write(SolicitudesCompanion(syncError: Value(error)));
  }

  /// Limpia el error (al reintentar) → vuelve a "Pendiente".
  Future<void> limpiarErrorSync(String clientId) async {
    await (_db.update(_db.solicitudes)..where((t) => t.id.equals(clientId)))
        .write(const SolicitudesCompanion(syncError: Value(null)));
  }

  /// Inserta una solicitud creada offline (aparece en la lista con badge).
  /// Su `id` es el clientId temporal hasta que el backend devuelva el real.
  Future<void> insertarPendiente({
    required String clientId,
    String? tramiteId,
    String? tramiteNombre,
  }) async {
    await _db.into(_db.solicitudes).insertOnConflictUpdate(
          SolicitudesCompanion(
            id: Value(clientId),
            tramiteId: Value(tramiteId),
            tramiteNombre: Value(tramiteNombre),
            estado: Value(EstadoSolicitud.pendiente.name),
            fechaCreacion: Value(DateTime.now()),
            pendienteSync: const Value(true),
            clientId: Value(clientId),
            actualizadoEn: Value(DateTime.now()),
          ),
        );
  }

  /// Borra la solicitud local temporal (tras sincronizarse con éxito).
  Future<void> eliminarPorClientId(String clientId) async {
    await (_db.delete(_db.solicitudes)..where((t) => t.id.equals(clientId)))
        .go();
  }

  /// Detalle completo de una solicitud (desde el JSON guardado), o null si
  /// todavía no se trajo el detalle.
  Future<SolicitudDetalle?> getSolicitud(String id) async {
    final row = await (_db.select(_db.solicitudes)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    final json = row?.detalleJson;
    if (json == null) return null;
    return SolicitudDetalle.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// Guarda los resúmenes (lista) sin pisar el detalle ya cacheado.
  Future<void> guardarResumenes(List<SolicitudResumen> lista) async {
    await _db.batch((batch) {
      for (final s in lista) {
        final companion = SolicitudesCompanion(
          id: Value(s.id),
          tramiteId: Value(s.tramiteId),
          tramiteNombre: Value(s.tramiteNombre),
          estado: Value(s.estado.name),
          fechaCreacion: Value(s.fechaCreacion),
          fechaFinalizacion: Value(s.fechaFinalizacion),
          actualizadoEn: Value(DateTime.now()),
          // detalleJson ausente → no se toca (preserva el detalle existente).
        );
        batch.insert(
          _db.solicitudes,
          companion,
          onConflict: DoUpdate((_) => companion),
        );
      }
    });
  }

  /// Guarda el detalle completo (incluye historial) + actualiza columnas.
  Future<void> guardarDetalle(SolicitudDetalle d) async {
    await _db.into(_db.solicitudes).insertOnConflictUpdate(
          SolicitudesCompanion(
            id: Value(d.id),
            tramiteId: Value(d.tramiteId),
            tramiteNombre: Value(d.tramiteNombre),
            estado: Value(d.estado.name),
            fechaCreacion: Value(d.fechaCreacion),
            fechaFinalizacion: Value(d.fechaFinalizacion),
            detalleJson: Value(jsonEncode(d.toJson())),
            actualizadoEn: Value(DateTime.now()),
          ),
        );
  }

  SolicitudResumen _aResumen(SolicitudRow row) {
    return SolicitudResumen(
      id: row.id,
      tramiteId: row.tramiteId,
      tramiteNombre: row.tramiteNombre,
      estado: _estado(row.estado),
      fechaCreacion:
          row.fechaCreacion ?? DateTime.fromMillisecondsSinceEpoch(0),
      fechaFinalizacion: row.fechaFinalizacion,
    );
  }

  EstadoSolicitud _estado(String? name) {
    if (name == null) return EstadoSolicitud.desconocido;
    try {
      return EstadoSolicitud.values.byName(name);
    } catch (_) {
      return EstadoSolicitud.desconocido;
    }
  }
}
