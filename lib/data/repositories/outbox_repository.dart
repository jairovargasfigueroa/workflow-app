import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:tramites_app/data/local/app_database.dart';

/// Cola de escrituras pendientes (Outbox Pattern). FIFO por `id`.
class OutboxRepository {
  final AppDatabase _db;

  OutboxRepository(this._db);

  Future<void> encolarCrearSolicitud({
    required String clientId,
    required String tramiteId,
    required List<Map<String, String>> respuestas,
    required List<Map<String, dynamic>> archivos,
  }) async {
    final payload = jsonEncode({
      'tramiteId': tramiteId,
      'respuestas': respuestas,
      'archivos': archivos, // [{campo, pathLocal, nombre}]
    });
    await _db.into(_db.outboxOperaciones).insert(
          OutboxOperacionesCompanion.insert(
            clientId: clientId,
            tipo: 'crear_solicitud',
            payloadJson: payload,
            creadoEn: Value(DateTime.now()),
          ),
        );
  }

  /// Operaciones pendientes (no en error), en orden FIFO.
  Future<List<OutboxRow>> getPendientes() {
    return (_db.select(_db.outboxOperaciones)
          ..where((t) => t.estado.equals('pendiente'))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  /// Todas (para indicadores: cuántas pendientes / con error).
  Stream<List<OutboxRow>> watchTodas() {
    return (_db.select(_db.outboxOperaciones)
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .watch();
  }

  Future<void> eliminar(int id) async {
    await (_db.delete(_db.outboxOperaciones)..where((t) => t.id.equals(id)))
        .go();
  }

  /// Elimina la operación por clientId (lo usa "Descartar" en la UI).
  Future<void> eliminarPorClientId(String clientId) async {
    await (_db.delete(_db.outboxOperaciones)
          ..where((t) => t.clientId.equals(clientId)))
        .go();
  }

  Future<void> incrementarIntento(int id, String error) async {
    final fila = await (_db.select(_db.outboxOperaciones)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (fila == null) return;
    await (_db.update(_db.outboxOperaciones)..where((t) => t.id.equals(id)))
        .write(
      OutboxOperacionesCompanion(
        intentos: Value(fila.intentos + 1),
        ultimoError: Value(error),
      ),
    );
  }

  Future<void> marcarError(int id, String error) async {
    await (_db.update(_db.outboxOperaciones)..where((t) => t.id.equals(id)))
        .write(
      OutboxOperacionesCompanion(
        estado: const Value('error'),
        ultimoError: Value(error),
      ),
    );
  }

  /// Reintentar manualmente una operación marcada con error.
  Future<void> reintentar(int id) async {
    await (_db.update(_db.outboxOperaciones)..where((t) => t.id.equals(id)))
        .write(
      const OutboxOperacionesCompanion(
        estado: Value('pendiente'),
        intentos: Value(0),
      ),
    );
  }

  /// Reintentar por clientId (lo usa la UI al tocar "Reintentar").
  Future<void> reintentarPorClientId(String clientId) async {
    await (_db.update(_db.outboxOperaciones)
          ..where((t) => t.clientId.equals(clientId)))
        .write(
      const OutboxOperacionesCompanion(
        estado: Value('pendiente'),
        intentos: Value(0),
        ultimoError: Value(null),
      ),
    );
  }
}
