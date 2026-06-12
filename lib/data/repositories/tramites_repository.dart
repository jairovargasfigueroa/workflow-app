import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:tramites_app/data/local/app_database.dart';
import 'package:tramites_app/models/documento_kit.dart';
import 'package:tramites_app/models/tramite.dart';

/// Lee/escribe el catálogo de trámites, formularios y kit en Drift.
class TramitesRepository {
  final AppDatabase _db;

  TramitesRepository(this._db);

  // --- Catálogo de trámites ---------------------------------------------

  Stream<List<TramiteDisponible>> watchTramites() {
    final query = _db.select(_db.tramites)
      ..orderBy([(t) => OrderingTerm.asc(t.nombre)]);
    return query.watch().map(
          (rows) => rows
              .map((r) => TramiteDisponible.fromJson(
                  jsonDecode(r.json) as Map<String, dynamic>))
              .toList(),
        );
  }

  /// Lectura one-shot de los trámites cacheados (la usa el buscador offline).
  Future<List<TramiteDisponible>> getTramites() async {
    final rows = await (_db.select(_db.tramites)
          ..orderBy([(t) => OrderingTerm.asc(t.nombre)]))
        .get();
    return rows
        .map((r) =>
            TramiteDisponible.fromJson(jsonDecode(r.json) as Map<String, dynamic>))
        .toList();
  }

  Future<void> guardarTramites(List<TramiteDisponible> lista) async {
    await _db.batch((batch) {
      for (final t in lista) {
        final companion = TramitesCompanion.insert(
          id: t.id,
          nombre: Value(t.nombre),
          descripcion: Value(t.descripcion),
          formularioSolicitanteId: Value(t.formularioSolicitanteId),
          activo: Value(t.activo),
          json: jsonEncode(t.toJson()),
          actualizadoEn: Value(DateTime.now()),
        );
        batch.insert(
          _db.tramites,
          companion,
          onConflict: DoUpdate((_) => companion),
        );
      }
    });
  }

  // --- Formulario (caché on-demand) -------------------------------------

  Future<FormularioTemplate?> getFormulario(String id) async {
    final row = await (_db.select(_db.formulariosCache)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return FormularioTemplate.fromJson(
        jsonDecode(row.json) as Map<String, dynamic>);
  }

  Future<void> guardarFormulario(FormularioTemplate f) async {
    await _db.into(_db.formulariosCache).insertOnConflictUpdate(
          FormulariosCacheCompanion.insert(
            id: f.id,
            json: jsonEncode(f.toJson()),
            actualizadoEn: Value(DateTime.now()),
          ),
        );
  }

  // --- Kit de documentos (caché on-demand) ------------------------------

  Future<List<DocumentoKit>> getKit(String tramiteId) async {
    final row = await (_db.select(_db.documentosKitCache)
          ..where((t) => t.tramiteId.equals(tramiteId)))
        .getSingleOrNull();
    if (row == null) return const [];
    final lista = jsonDecode(row.json) as List<dynamic>;
    return lista
        .map((e) => DocumentoKit.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> guardarKit(String tramiteId, List<DocumentoKit> kit) async {
    await _db.into(_db.documentosKitCache).insertOnConflictUpdate(
          DocumentosKitCacheCompanion.insert(
            tramiteId: tramiteId,
            json: jsonEncode(kit.map((d) => d.toJson()).toList()),
            actualizadoEn: Value(DateTime.now()),
          ),
        );
  }
}
