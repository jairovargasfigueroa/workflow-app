import 'package:flutter/foundation.dart';
import 'package:tramites_app/data/repositories/tramites_repository.dart';
import 'package:tramites_app/models/archivo_para_subir.dart';
import 'package:tramites_app/models/contenido_interactivo.dart';
import 'package:tramites_app/models/evento_sse.dart';
import 'package:tramites_app/models/mensaje_chat.dart';
import 'package:tramites_app/services/agente_tramites_service.dart';
import 'package:tramites_app/services/buscador_tramites.dart';
import 'package:tramites_app/services/asistente_local.dart';
import 'package:uuid/uuid.dart';

/// Estado de la conversación con el agente de trámites.
///
/// Fase 1: texto (streaming), indicador de herramienta, errores.
/// Fase 2: opciones (botones), formulario dinámico, correcciones, resumen,
/// y el envío de las respuestas del usuario de vuelta al agente.
class AgenteTramitesProvider extends ChangeNotifier {
  final AgenteTramitesService _service;
  final TramitesRepository _tramitesRepo;
  final AsistenteLocal _asistente;
  final _uuid = const Uuid();

  AgenteTramitesProvider(this._service, this._tramitesRepo, this._asistente);

  /// La asigna el micro en el primer turno vía el evento `sesion`.
  /// Es null hasta entonces (contrato v1.0: "uuid o null si es nueva").
  String? _sesionId;
  String? get sesionId => _sesionId;

  final List<MensajeChat> _mensajes = [];
  List<MensajeChat> get mensajes => List.unmodifiable(_mensajes);

  bool _enviando = false;
  bool get enviando => _enviando;

  String? _toolActiva;
  String? get toolActiva => _toolActiva;

  String? _error;
  String? get error => _error;

  /// ID de la última solicitud creada (se usa para subir los archivos).
  String? _ultimaSolicitudId;
  String? get ultimaSolicitudId => _ultimaSolicitudId;

  /// Archivos elegidos en el formulario, retenidos hasta que el agente pida
  /// subirlos (evento `subir_archivos`). Clave = nombre del campo.
  final Map<String, ArchivoParaSubir> _archivosAgente = {};

  /// Evento `subir_archivos` recibido durante el stream; se procesa al cerrar.
  EventoSSE? _subirArchivosEvento;

  bool get estaVacio => _mensajes.isEmpty;

  // --- Acciones del usuario ---------------------------------------------

  /// Envía un mensaje de texto escrito por el usuario.
  Future<void> enviar(String texto) =>
      _enviarAlAgente(mensaje: texto.trim(), textoMostrado: texto.trim());

  /// Precarga el modelo local en RAM (idempotente). Llamar al entrar al chat
  /// para que la "primera carga lenta" pase antes de que el usuario escriba.
  Future<void> prepararAsistenteOffline() => _asistente.preparar();

  /// ¿El asistente local está listo (modelo cargado)?
  bool get asistenteListo => _asistente.listo;

  /// Modo offline: responde con el **LLM local** (deep learning on-device).
  /// Entiende lenguaje natural, valida, recomienda un trámite del catálogo
  /// cacheado y —si recomienda— ofrece iniciar el formulario.
  Future<void> responderOffline(String texto) async {
    final limpio = texto.trim();
    if (limpio.isEmpty || _enviando) return;

    _mensajes.add(
      MensajeChat(
        id: _uuid.v4(),
        rol: RolMensaje.usuario,
        tipo: TipoMensaje.texto,
        contenido: limpio,
      ),
    );
    _enviando = true;
    _error = null;

    // Burbuja del agente: aparece YA, vacía → la UI muestra "pensando…" (puntitos)
    // mientras carga el modelo y espera el primer token. Después se llena.
    final burbuja = MensajeChat(
      id: _uuid.v4(),
      rol: RolMensaje.agente,
      tipo: TipoMensaje.texto,
      contenido: '',
    );
    _mensajes.add(burbuja);
    notifyListeners();

    try {
      // Asegurar el modelo cargado (espera a que termine; NO necesita internet).
      if (!_asistente.listo) await _asistente.preparar();
      if (!_asistente.listo) {
        burbuja.contenido = 'No pude preparar el asistente local. Esperá unos '
            'segundos y volvé a escribir.';
        return;
      }

      final catalogo = await _tramitesRepo.getTramites();
      final activos = catalogo.where((t) => t.activo).toList();

      // Portero (código, determinístico): trae los trámites relevantes. Si no hay
      // NINGUNO → es off-topic → rechazo confiable, sin molestar al modelo.
      final candidatos = BuscadorTramites.buscar(limpio, activos, max: 5);
      if (candidatos.isEmpty) {
        burbuja.contenido = 'Perdoná, solo puedo ayudarte con trámites. Contame '
            'qué gestión necesitás (por ejemplo, una constancia o un certificado).';
        return;
      }

      // El modelo (inteligente): entre los candidatos relevantes, entiende y
      // elige el mejor + responde natural. El marcador es el número (1..N).
      final buffer = StringBuffer();
      await for (final token in _asistente.responder(limpio, candidatos)) {
        buffer.write(token);
        burbuja.contenido = limpiarTextoAsistente(buffer.toString());
        notifyListeners();
      }

      final numero = extraerNumeroTramite(buffer.toString());
      final tramite =
          (numero != null && numero >= 1 && numero <= candidatos.length)
              ? candidatos[numero - 1]
              : null;

      // Si quedó vacío (devolvió solo el marcador), texto de respaldo.
      if (burbuja.contenido.trim().isEmpty) {
        burbuja.contenido = tramite != null
            ? 'Creo que te sirve este trámite:'
            : 'Perdoná, no te entendí bien. ¿Me das un poco más de detalle?';
        notifyListeners();
      }

      // Botón para iniciar el trámite recomendado.
      if (tramite != null) {
        _mensajes.add(
          MensajeChat(
            id: _uuid.v4(),
            rol: RolMensaje.agente,
            tipo: TipoMensaje.sugerencias,
            contenido: '',
            tramites: [tramite],
          ),
        );
      }
    } catch (e) {
      burbuja.contenido = 'Tuve un problema procesando eso. Probá de nuevo.';
      debugPrint('[AGENTE-LOCAL] $e');
    } finally {
      _enviando = false;
      notifyListeners();
    }
  }

  /// El usuario eligió una opción (botón).
  Future<void> elegirOpcion(MensajeChat mensaje, OpcionAgente opcion) async {
    if (mensaje.respondido || _enviando) return;
    mensaje.respondido = true;
    notifyListeners();
    await _enviarAlAgente(mensaje: opcion.valor, textoMostrado: opcion.etiqueta);
  }

  /// El usuario completó el formulario y tocó "Confirmar".
  Future<void> enviarFormulario(
    MensajeChat formulario,
    Map<String, String> datos,
    List<ArchivoParaSubir> archivos,
  ) async {
    if (formulario.respondido || _enviando) return;
    formulario.respondido = true;
    formulario.errores = {};

    // Retener los archivos (se suben cuando llegue `subir_archivos`) y mandar
    // su ficha (archivosListos) al agente.
    _archivosAgente
      ..clear()
      ..addEntries(archivos.map((a) => MapEntry(a.campoFormulario, a)));
    final archivosListos = archivos
        .map((a) => <String, dynamic>{
              'campo': a.campoFormulario,
              'nombre': a.nombre,
              'tamano': a.tamanoBytes,
              'contentType': _contentType(a),
            })
        .toList();

    notifyListeners();
    await _enviarAlAgente(
      mensaje: '[camposCompletos]',
      textoMostrado: '✓ Datos enviados',
      datos: datos.map((k, v) => MapEntry(k, v as dynamic)),
      archivosListos: archivosListos.isEmpty ? null : archivosListos,
    );
  }

  /// El usuario confirmó el resumen.
  Future<void> confirmarResumen(MensajeChat resumen) async {
    if (resumen.respondido || _enviando) return;
    resumen.respondido = true;
    notifyListeners();
    await _enviarAlAgente(
      mensaje: '[confirmar]',
      textoMostrado: '✅ Confirmar y enviar',
    );
  }

  /// El usuario pidió modificar desde el resumen.
  /// El contrato v1.0 no define marcador para "modificar", así que se manda
  /// texto libre (el agente lo interpreta).
  Future<void> modificarResumen(MensajeChat resumen) async {
    if (resumen.respondido || _enviando) return;
    resumen.respondido = true;
    notifyListeners();
    await _enviarAlAgente(
      mensaje: 'Quiero modificar los datos',
      textoMostrado: '✏️ Modificar',
    );
  }

  // --- Núcleo: envío + consumo del stream -------------------------------

  Future<void> _enviarAlAgente({
    required String mensaje,
    required String textoMostrado,
    Map<String, dynamic>? datos,
    List<Map<String, dynamic>>? archivosListos,
  }) async {
    if (mensaje.isEmpty || _enviando) return;

    _mensajes.add(
      MensajeChat(
        id: _uuid.v4(),
        rol: RolMensaje.usuario,
        tipo: TipoMensaje.texto,
        contenido: textoMostrado,
      ),
    );
    _enviando = true;
    _error = null;
    _toolActiva = null;
    notifyListeners();

    // Burbuja del agente donde se acumulan los fragmentos `texto`.
    MensajeChat? burbujaAgente;

    void agregarFragmento(String fragmento) {
      if (burbujaAgente == null) {
        burbujaAgente = MensajeChat(
          id: _uuid.v4(),
          rol: RolMensaje.agente,
          tipo: TipoMensaje.texto,
          contenido: fragmento,
        );
        _mensajes.add(burbujaAgente!);
      } else {
        burbujaAgente!.contenido += fragmento;
      }
    }

    try {
      final stream = _service.enviarMensaje(
        sesionId: _sesionId,
        clientMessageId: _uuid.v4(),
        mensaje: mensaje,
        datos: datos,
        archivosListos: archivosListos,
      );

      await for (final evento in stream) {
        switch (evento.tipo) {
          case TipoEventoSSE.sesion:
            // El micro asigna/confirma el sesionId; lo guardamos para
            // los próximos mensajes (y la recuperación de sesión en Fase 5).
            if (evento.sesionId != null) _sesionId = evento.sesionId;
            break;

          case TipoEventoSSE.toolCall:
            burbujaAgente = null;
            _toolActiva = evento.nombre ?? 'una herramienta';
            notifyListeners();
            break;

          case TipoEventoSSE.toolResult:
            _toolActiva = null;
            notifyListeners();
            break;

          case TipoEventoSSE.texto:
            _toolActiva = null;
            agregarFragmento(evento.contenido ?? '');
            notifyListeners();
            break;

          case TipoEventoSSE.mostrarOpciones:
            burbujaAgente = null;
            _toolActiva = null;
            _mensajes.add(
              MensajeChat(
                id: _uuid.v4(),
                rol: RolMensaje.agente,
                tipo: TipoMensaje.opciones,
                contenido: evento.textoIntro ?? '',
                opciones: evento.opciones,
              ),
            );
            notifyListeners();
            break;

          case TipoEventoSSE.pedirCamposMultiples:
            burbujaAgente = null;
            _toolActiva = null;
            _mensajes.add(
              MensajeChat(
                id: _uuid.v4(),
                rol: RolMensaje.agente,
                tipo: TipoMensaje.formulario,
                contenido: evento.textoIntro ?? '',
                titulo: evento.titulo,
                campos: evento.campos,
              ),
            );
            notifyListeners();
            break;

          case TipoEventoSSE.pedirCorrecciones:
            _toolActiva = null;
            _aplicarCorrecciones(evento);
            notifyListeners();
            break;

          case TipoEventoSSE.mostrarResumen:
            burbujaAgente = null;
            _toolActiva = null;
            _mensajes.add(
              MensajeChat(
                id: _uuid.v4(),
                rol: RolMensaje.agente,
                tipo: TipoMensaje.resumen,
                contenido: evento.textoIntro ?? '',
                titulo: evento.titulo,
                items: evento.itemsResumen,
                archivos: evento.nombresArchivosResumen,
              ),
            );
            notifyListeners();
            break;

          case TipoEventoSSE.solicitudCreada:
            burbujaAgente = null;
            _toolActiva = null;
            _ultimaSolicitudId = evento.solicitudId;
            final numero = evento.numeroSolicitud;
            _mensajes.add(
              MensajeChat(
                id: _uuid.v4(),
                rol: RolMensaje.agente,
                tipo: TipoMensaje.sistema,
                contenido: numero != null
                    ? '✅ Solicitud #$numero creada.'
                    : '✅ Solicitud creada.',
              ),
            );
            notifyListeners();
            break;

          case TipoEventoSSE.error:
            _error = evento.mensajeError ?? 'Ocurrió un error en el asistente.';
            notifyListeners();
            break;

          case TipoEventoSSE.fin:
            break;

          // El agente pide subir los archivos retenidos. Se procesa al cerrar
          // el stream (no se puede abrir otro request desde adentro del actual).
          case TipoEventoSSE.subirArchivos:
            _subirArchivosEvento = evento;
            if (evento.solicitudId != null) {
              _ultimaSolicitudId = evento.solicitudId;
            }
            break;

          case TipoEventoSSE.desconocido:
            debugPrint('[AGENTE] Evento desconocido: ${evento.data}');
            break;
        }
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _toolActiva = null;
      _enviando = false;
      notifyListeners();

      // Si el agente pidió subir archivos, hacerlo ahora (fuera del stream).
      final pendiente = _subirArchivosEvento;
      _subirArchivosEvento = null;
      if (pendiente != null) {
        await _procesarSubirArchivos(pendiente);
      }
    }
  }

  /// Sube los archivos retenidos y avisa al agente con `[archivosSubidos]`.
  Future<void> _procesarSubirArchivos(EventoSSE evento) async {
    final solicitudId = evento.solicitudId ?? _ultimaSolicitudId;
    if (solicitudId == null) {
      debugPrint('[AGENTE] subir_archivos sin solicitudId');
      return;
    }

    _mensajes.add(
      MensajeChat(
        id: _uuid.v4(),
        rol: RolMensaje.agente,
        tipo: TipoMensaje.sistema,
        contenido: 'Subiendo archivos…',
      ),
    );
    notifyListeners();

    // Qué campos subir: los que pidió el evento, o todos los retenidos.
    final pedidos = evento.archivosASubir
        .map((m) => (m['campo'] ?? '').toString())
        .where((c) => c.isNotEmpty)
        .toList();
    final campos = pedidos.isNotEmpty ? pedidos : _archivosAgente.keys.toList();

    for (final campo in campos) {
      final archivo = _archivosAgente[campo];
      if (archivo == null) continue;
      try {
        await _service.subirArchivo(
          solicitudId: solicitudId,
          campoFormulario: campo,
          filePath: archivo.path,
          fileName: archivo.nombre,
        );
      } catch (e) {
        debugPrint('[AGENTE] Falló subir $campo: $e');
      }
    }
    _archivosAgente.clear();

    // Avisar al agente que ya están subidos → emite el texto final + fin.
    await _enviarAlAgente(
      mensaje: '[archivosSubidos]',
      textoMostrado: '📎 Archivos subidos',
    );
  }

  /// MIME a partir de la extensión del archivo (para la ficha archivosListos).
  String _contentType(ArchivoParaSubir a) {
    switch (a.extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      default:
        return 'application/octet-stream';
    }
  }

  /// Aplica errores de validación al último formulario y lo reactiva para editar.
  void _aplicarCorrecciones(EventoSSE evento) {
    final errores = evento.errores;
    final form = _ultimoFormulario();
    if (form != null) {
      form.errores = errores;
      form.respondido = false;
    } else {
      _mensajes.add(
        MensajeChat(
          id: _uuid.v4(),
          rol: RolMensaje.agente,
          tipo: TipoMensaje.error,
          contenido: evento.textoIntro ?? 'Hay campos para corregir.',
        ),
      );
    }
  }

  MensajeChat? _ultimoFormulario() {
    for (var i = _mensajes.length - 1; i >= 0; i--) {
      if (_mensajes[i].tipo == TipoMensaje.formulario) return _mensajes[i];
    }
    return null;
  }

  // --- Utilidades -------------------------------------------------------

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  void reiniciar() {
    _mensajes.clear();
    _sesionId = null;
    _enviando = false;
    _toolActiva = null;
    _error = null;
    _ultimaSolicitudId = null;
    _archivosAgente.clear();
    _subirArchivosEvento = null;
    notifyListeners();
  }
}
