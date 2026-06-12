import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:tramites_app/data/local/app_database.dart';
import 'package:tramites_app/data/local/file_storage_service.dart';
import 'package:tramites_app/data/repositories/archivos_repository.dart';
import 'package:tramites_app/data/repositories/outbox_repository.dart';
import 'package:tramites_app/data/repositories/solicitudes_repository.dart';
import 'package:tramites_app/data/repositories/tramites_repository.dart';
import 'package:tramites_app/models/tramite.dart';
import 'package:tramites_app/services/api_service.dart';

/// Resultado de procesar una operación de la cola.
/// - [ok]: subió bien.
/// - [permanente]: falló y no sirve reintentar (4xx o agotó intentos) → se marca
///   error y la cola **sigue** con las demás.
/// - [transitorio]: falló por algo pasajero (sin red / 5xx) → la cola **frena**
///   para preservar el orden y reintenta en la próxima activación.
enum _ResultadoSync { ok, permanente, transitorio }

/// Orquesta la sincronización: primero **vacía la cola (Outbox)** subiendo lo
/// pendiente, luego hace el **pull** del estado fresco a Drift.
///
/// Todo best-effort: offline o con fallas no rompe — la UI sigue con lo local.
class SyncManager {
  final ApiService _api;
  final SolicitudesRepository _solicitudesRepo;
  final TramitesRepository _tramitesRepo;
  final OutboxRepository _outboxRepo;
  final FileStorageService _fileStorage;
  final ArchivosRepository _archivosRepo;

  SyncManager(
    this._api,
    this._solicitudesRepo,
    this._tramitesRepo,
    this._outboxRepo,
    this._fileStorage,
    this._archivosRepo,
  );

  bool _sincronizandoSolicitudes = false;
  bool _procesandoOutbox = false;

  /// Activación completa (al abrir / reconectar / FCM): primero sube la cola,
  /// después baja el estado fresco.
  Future<void> prefetchInicial() async {
    await procesarOutbox();
    await Future.wait([
      sincronizarTramites(),
      sincronizarSolicitudes(),
    ]);
  }

  // --- Cola de escrituras (Outbox) --------------------------------------

  /// Procesa la cola en orden FIFO estricto: no pasa a la siguiente hasta que
  /// la actual confirme OK. Reintentos máx. 3 (acumulados entre activaciones).
  Future<void> procesarOutbox() async {
    if (_procesandoOutbox) return;
    _procesandoOutbox = true;
    try {
      final pendientes = await _outboxRepo.getPendientes();
      for (final op in pendientes) {
        final resultado = await _procesar(op);
        // Solo frenamos ante un error transitorio (sin red): preserva el orden
        // y reintenta luego. Un error permanente se marca y seguimos con las otras.
        if (resultado == _ResultadoSync.transitorio) break;
      }
    } catch (e) {
      debugPrint('[SYNC] procesarOutbox falló: $e');
    } finally {
      _procesandoOutbox = false;
    }
  }

  /// Reintento manual (botón "Reintentar" en una solicitud con error).
  Future<void> reintentar(String clientId) async {
    await _outboxRepo.reintentarPorClientId(clientId);
    await _solicitudesRepo.limpiarErrorSync(clientId);
    await procesarOutbox();
  }

  Future<_ResultadoSync> _procesar(OutboxRow op) async {
    final payload = jsonDecode(op.payloadJson) as Map<String, dynamic>;
    final respuestas = (payload['respuestas'] as List)
        .map((e) =>
            (e as Map).map((k, v) => MapEntry(k.toString(), v.toString())))
        .toList();

    // === Fase 1: crear la solicitud (idempotente por clientId) ===
    final String solicitudId;
    try {
      final detalle = await _api.createSolicitud(
        tramiteId: payload['tramiteId'] as String,
        respuestasSolicitante: respuestas,
        clientId: op.clientId,
      );
      solicitudId = detalle.id;
      // Ya existe en el server → borrar la local temporal para que NO quede
      // duplicada con la real que baja el pull (aunque luego falle una subida).
      await _solicitudesRepo.eliminarPorClientId(op.clientId);
    } on ApiException catch (e) {
      if (e.esPermanente) {
        await _marcarError(op, e.mensaje);
        debugPrint('[SYNC] Crear ERROR permanente (${e.statusCode}): '
            '${op.clientId} — ${e.mensaje}');
        return _ResultadoSync.permanente;
      }
      return _transitorio(op, e.mensaje);
    } catch (e) {
      return _transitorio(op, e.toString().replaceFirst('Exception: ', ''));
    }

    // === Fase 2: subir los archivos (cada uno con su propio clientId) ===
    try {
      final archivos = (payload['archivos'] as List?) ?? const [];
      for (final a in archivos) {
        final m = a as Map<String, dynamic>;
        await _api.subirArchivo(
          solicitudId: solicitudId,
          campoFormulario: m['campo'] as String,
          filePath: m['pathLocal'] as String,
          fileName: m['nombre'] as String,
          clientId: (m['clientId'] as String?) ?? op.clientId,
        );
      }
      // Todo subido → limpiar archivos locales + sacar de la cola.
      await _fileStorage.borrarDeClientId(op.clientId);
      await _outboxRepo.eliminar(op.id);
      debugPrint('[SYNC] Outbox OK: ${op.clientId} → $solicitudId');
      return _ResultadoSync.ok;
    } on ApiException catch (e) {
      if (e.esPermanente) {
        // La solicitud YA se creó; solo falló una subida → marcar la op en error
        // (no hay duplicado; el reintento re-sube por idempotencia).
        await _outboxRepo.marcarError(op.id, e.mensaje);
        debugPrint('[SYNC] Subida ERROR permanente: ${op.clientId} — ${e.mensaje}');
        return _ResultadoSync.permanente;
      }
      return _transitorio(op, e.mensaje);
    } catch (e) {
      return _transitorio(op, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<_ResultadoSync> _transitorio(OutboxRow op, String msg) async {
    final intentos = op.intentos + 1;
    if (intentos >= 3) {
      // Agotó los reintentos → marcar error (deja de bloquear la cola).
      await _marcarError(op, msg);
      debugPrint('[SYNC] Outbox ERROR (3 intentos): ${op.clientId} — $msg');
      return _ResultadoSync.permanente;
    }
    await _outboxRepo.incrementarIntento(op.id, msg);
    debugPrint('[SYNC] Outbox reintento $intentos: ${op.clientId} — $msg');
    return _ResultadoSync.transitorio;
  }

  Future<void> _marcarError(OutboxRow op, String msg) async {
    await _outboxRepo.marcarError(op.id, msg);
    await _solicitudesRepo.marcarErrorSync(op.clientId, msg);
  }

  // --- Pull (prefetch) --------------------------------------------------

  /// Catálogo de trámites. Devuelve true si trajo datos del backend.
  /// Tras cachear el catálogo, dispara (en segundo plano) el prefetch de los
  /// formularios y kits de cada trámite → quedan disponibles offline sin tener
  /// que abrir cada uno online primero. No bloquea: la lista se ve al instante.
  Future<bool> sincronizarTramites() async {
    final List<TramiteDisponible> tramites;
    try {
      tramites = await _api.getTramites();
      await _tramitesRepo.guardarTramites(tramites);
      debugPrint('[SYNC] tramites: ${tramites.length}');
    } catch (e) {
      debugPrint('[SYNC] tramites falló (¿offline?): $e');
      return false;
    }
    unawaited(_prefetchFormulariosYKits(tramites));
    return true;
  }

  /// Precarga formularios + kits de cada trámite activo (best-effort por ítem).
  /// Se ejecuta en background: si uno falla, no corta los demás ni la app.
  Future<void> _prefetchFormulariosYKits(List<TramiteDisponible> tramites) async {
    var formularios = 0;
    var kits = 0;
    for (final t in tramites) {
      if (!t.activo) continue;
      final formId = t.formularioSolicitanteId;
      if (formId != null && formId.isNotEmpty) {
        try {
          await _tramitesRepo.guardarFormulario(await _api.getFormulario(formId));
          formularios++;
        } catch (e) {
          debugPrint('[SYNC] prefetch formulario ${t.id} falló: $e');
        }
      }
      try {
        await _tramitesRepo.guardarKit(t.id, await _api.getDocumentosKit(t.id));
        kits++;
      } catch (e) {
        debugPrint('[SYNC] prefetch kit ${t.id} falló: $e');
      }
    }
    debugPrint('[SYNC] prefetch listo: $formularios formularios, $kits kits');
  }

  /// Solicitudes del usuario. Trae **solo los resúmenes** (1 llamada) → con eso
  /// la lista ya se puede mostrar. El detalle + archivos de cada una se bajan
  /// **en segundo plano** (no bloquea la lista) para tenerlos offline.
  /// Devuelve true si trajo la lista del backend.
  Future<bool> sincronizarSolicitudes() async {
    if (_sincronizandoSolicitudes) return false;
    _sincronizandoSolicitudes = true;
    try {
      final resumenes = await _api.getMisSolicitudes();
      await _solicitudesRepo.guardarResumenes(resumenes);
      debugPrint('[SYNC] solicitudes: ${resumenes.length}');
      unawaited(_prefetchDetallesSolicitudes(resumenes));
      return true;
    } catch (e) {
      debugPrint('[SYNC] solicitudes falló (¿offline?): $e');
      return false;
    } finally {
      _sincronizandoSolicitudes = false;
    }
  }

  bool _prefetchDetallesEnCurso = false;

  /// Baja el detalle + archivos de cada solicitud en segundo plano, para tenerlos
  /// disponibles offline sin bloquear la lista. Best-effort por ítem.
  Future<void> _prefetchDetallesSolicitudes(
    List<SolicitudResumen> resumenes,
  ) async {
    if (_prefetchDetallesEnCurso) return;
    _prefetchDetallesEnCurso = true;
    try {
      for (final r in resumenes) {
        try {
          final detalle = await _api.getSolicitud(r.id);
          await _solicitudesRepo.guardarDetalle(detalle);
        } catch (e) {
          debugPrint('[SYNC] detalle ${r.id} falló: $e');
        }
        // Cachear la lista de archivos (ficha) para verla offline.
        try {
          final archivos = await _api.getArchivosDeSolicitud(r.id);
          await _archivosRepo.guardarArchivos(r.id, archivos);
        } catch (e) {
          debugPrint('[SYNC] archivos ${r.id} falló: $e');
        }
      }
    } finally {
      _prefetchDetallesEnCurso = false;
    }
  }

  /// Descarta una solicitud que quedó en error (nunca llegó al server): borra
  /// la fila local, su operación en la cola y los archivos guardados en disco.
  Future<void> descartar(String clientId) async {
    await _outboxRepo.eliminarPorClientId(clientId);
    await _solicitudesRepo.eliminarPorClientId(clientId);
    await _fileStorage.borrarDeClientId(clientId);
    debugPrint('[SYNC] descartada: $clientId');
  }
}
