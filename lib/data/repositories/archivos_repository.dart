import 'package:drift/drift.dart';
import 'package:tramites_app/data/local/app_database.dart';
import 'package:tramites_app/models/archivo_response.dart';

/// Caché local de la metadata de archivos + la ruta del binario descargado
/// (para verlos offline). El binario vive en el filesystem, acá solo la ficha.
class ArchivosRepository {
  final AppDatabase _db;

  ArchivosRepository(this._db);

  Future<List<ArchivoResponse>> getArchivos(String solicitudId) async {
    final rows = await (_db.select(_db.archivos)
          ..where((t) => t.solicitudId.equals(solicitudId)))
        .get();
    return rows.map(_aResponse).toList();
  }

  Future<void> guardarArchivos(
    String solicitudId,
    List<ArchivoResponse> lista,
  ) async {
    await _db.batch((batch) {
      for (final a in lista) {
        // pathLocal ausente → preserva la descarga existente si la había.
        final companion = ArchivosCompanion(
          id: Value(a.id),
          solicitudId: Value(solicitudId),
          nombre: Value(a.nombre),
          formato: Value(a.formato),
          contentType: Value(a.contentType),
          tamanoBytes: Value(a.tamanoBytes),
          campoFormularioOrigen: Value(a.campoFormularioOrigen),
          actualizadoEn: Value(DateTime.now()),
        );
        batch.insert(
          _db.archivos,
          companion,
          onConflict: DoUpdate((_) => companion),
        );
      }
    });
  }

  Future<String?> getPathLocal(String archivoId) async {
    final row = await (_db.select(_db.archivos)
          ..where((t) => t.id.equals(archivoId)))
        .getSingleOrNull();
    return row?.pathLocal;
  }

  Future<void> setPathLocal(String archivoId, String path) async {
    await (_db.update(_db.archivos)..where((t) => t.id.equals(archivoId)))
        .write(
      ArchivosCompanion(
        pathLocal: Value(path),
        actualizadoEn: Value(DateTime.now()),
      ),
    );
  }

  ArchivoResponse _aResponse(ArchivoRow row) => ArchivoResponse(
        id: row.id,
        solicitudId: row.solicitudId,
        nombre: row.nombre ?? '',
        formato: row.formato,
        contentType: row.contentType,
        tamanoBytes: row.tamanoBytes,
        campoFormularioOrigen: row.campoFormularioOrigen,
      );
}
