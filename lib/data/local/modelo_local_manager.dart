import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:path_provider/path_provider.dart';

/// Estado del modelo local (deep learning on-device).
enum EstadoModelo {
  noInstalado, // el archivo del modelo no está en el dispositivo todavía
  cargando, // se está cargando en RAM
  listo, // cargado y listo para inferir
  error, // falló la carga
}

/// Gestiona el modelo local: ubica el archivo en disco, lo carga en RAM (1 vez)
/// y expone una instancia lista para inferir. NO descarga por red: para la demo,
/// el archivo se empuja al celu con `adb push` a la carpeta de la app.
///
/// El motor (flutter_gemma / MediaPipe) vive en el APK; el modelo (pesos) en disco.
class ModeloLocalManager {
  /// Nombre con el que esperamos el archivo en la carpeta externa de la app.
  /// (Empujá el .task del modelo a esta ruta con adb — ver PLAN_AGENTE_LOCAL.md.)
  static const String nombreArchivo = 'gemma3-1b.task';

  /// Tamaño máximo de contexto (entrada + salida). Catálogo chico + respuesta corta.
  static const int maxTokens = 1024;

  InferenceModel? _modelo;
  EstadoModelo _estado = EstadoModelo.noInstalado;
  String? _error;

  InferenceModel? get modelo => _modelo;
  EstadoModelo get estado => _estado;
  String? get error => _error;
  bool get listo => _estado == EstadoModelo.listo && _modelo != null;

  /// Ruta donde se espera el archivo del modelo (carpeta externa de la app).
  Future<String> rutaModelo() async {
    final dir = await getExternalStorageDirectory() ??
        await getApplicationDocumentsDirectory();
    return '${dir.path}/$nombreArchivo';
  }

  /// ¿Está el archivo del modelo presente en el dispositivo?
  Future<bool> archivoPresente() async {
    return File(await rutaModelo()).exists();
  }

  Future<void>? _cargaEnCurso;

  /// Carga el modelo en RAM (idempotente). Si ya hay una carga en curso, los
  /// llamados concurrentes **esperan** a que termine (no se rinden antes). NO
  /// necesita internet: carga desde el archivo local. Best-effort: captura errores.
  Future<void> cargar() {
    if (listo) return Future<void>.value();
    return _cargaEnCurso ??= _cargarInterno();
  }

  Future<void> _cargarInterno() async {
    _estado = EstadoModelo.cargando;
    _error = null;
    try {
      final ruta = await rutaModelo();
      if (!await File(ruta).exists()) {
        _estado = EstadoModelo.noInstalado;
        debugPrint('[MODELO] no presente en $ruta');
        return;
      }
      // Registra el archivo local como modelo activo (idempotente).
      await FlutterGemma.installModel(
        modelType: ModelType.gemmaIt,
        fileType: ModelFileType.task,
      ).fromFile(ruta).install();
      // Lo carga en RAM. CPU: mejor en gama media (Adreno 610 es débil).
      _modelo = await FlutterGemma.getActiveModel(
        maxTokens: maxTokens,
        preferredBackend: PreferredBackend.cpu,
      );
      _estado = EstadoModelo.listo;
      debugPrint('[MODELO] listo');
    } catch (e) {
      _error = e.toString();
      _estado = EstadoModelo.error;
      debugPrint('[MODELO] error al cargar: $e');
    } finally {
      _cargaEnCurso = null;
    }
  }

  Future<void> dispose() async {
    await _modelo?.close();
    _modelo = null;
  }
}
