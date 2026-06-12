import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:tramites_app/models/archivo_para_subir.dart';

/// Guarda binarios en el filesystem del dispositivo (no en Drift).
///
/// - `outbox/<clientId>/...` → archivos a subir, retenidos hasta sincronizar.
/// - `descargas/...` → archivos descargados para verlos offline (Off-4).
///
/// (Por ahora sin cifrado, según lo acordado para la demo; el cifrado AES es
/// una mejora posterior: la llave iría en flutter_secure_storage.)
class FileStorageService {
  Future<Directory> _carpetaOutbox(String clientId) async {
    final dir = await getApplicationDocumentsDirectory();
    final carpeta = Directory('${dir.path}/outbox/$clientId');
    if (!await carpeta.exists()) await carpeta.create(recursive: true);
    return carpeta;
  }

  /// Copia un archivo elegido a la carpeta persistente del clientId.
  /// Devuelve la ruta nueva (la que se guarda en el Outbox).
  Future<String> guardarParaSubir(
    String clientId,
    ArchivoParaSubir archivo,
  ) async {
    final carpeta = await _carpetaOutbox(clientId);
    final seguro = archivo.nombre.replaceAll(RegExp(r'[^\w.\-]'), '_');
    final destino = '${carpeta.path}/${archivo.campoFormulario}__$seguro';
    await File(archivo.path).copy(destino);
    return destino;
  }

  /// Borra todos los archivos de un clientId (tras subir con éxito).
  Future<void> borrarDeClientId(String clientId) async {
    final dir = await getApplicationDocumentsDirectory();
    final carpeta = Directory('${dir.path}/outbox/$clientId');
    if (await carpeta.exists()) await carpeta.delete(recursive: true);
  }

  /// Ruta destino para un archivo descargado (Off-4).
  Future<String> rutaDescarga(String archivoId, String nombre) async {
    final dir = await getApplicationDocumentsDirectory();
    final carpeta = Directory('${dir.path}/descargas');
    if (!await carpeta.exists()) await carpeta.create(recursive: true);
    final seguro = nombre.replaceAll(RegExp(r'[^\w.\-]'), '_');
    return '${carpeta.path}/${archivoId}__$seguro';
  }

  /// Tope por defecto de la caché de descargas (200 MB).
  static const int maxBytesDescargas = 200 * 1024 * 1024;

  /// Mantiene la caché de descargas bajo un tope. Si se pasa, borra los
  /// archivos **menos usados primero** (LRU aproximado por fecha de
  /// modificación; al abrir un archivo se "toca" su fecha). Best-effort:
  /// cualquier falla se ignora, no rompe la app. Como [prepararArchivoLocal]
  /// re-descarga si el archivo no existe, evictar es seguro.
  Future<void> limpiarDescargas({int maxBytes = maxBytesDescargas}) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final carpeta = Directory('${dir.path}/descargas');
      if (!await carpeta.exists()) return;

      final archivos = <File>[];
      await for (final e in carpeta.list()) {
        if (e is File) archivos.add(e);
      }

      var total = 0;
      for (final f in archivos) {
        total += await f.length();
      }
      if (total <= maxBytes) return;

      // Menos usados primero (fecha de modificación más vieja).
      archivos.sort(
        (a, b) => a.statSync().modified.compareTo(b.statSync().modified),
      );
      for (final f in archivos) {
        if (total <= maxBytes) break;
        final size = await f.length();
        try {
          await f.delete();
          total -= size;
        } catch (_) {
          // un archivo que no se pudo borrar no debe frenar la limpieza
        }
      }
    } catch (_) {
      // best-effort
    }
  }

  /// Marca un archivo como "usado recién" (para el LRU). Best-effort.
  Future<void> tocar(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) f.setLastModifiedSync(DateTime.now());
    } catch (_) {}
  }
}
