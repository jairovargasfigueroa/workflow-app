import 'package:flutter/foundation.dart';
import 'package:tramites_app/models/contenido_interactivo.dart';
import 'package:tramites_app/models/evento_sse.dart';
import 'package:tramites_app/models/mensaje_chat.dart';
import 'package:tramites_app/services/agente_tramites_service.dart';
import 'package:uuid/uuid.dart';

/// Estado de la conversación con el agente de trámites.
///
/// Fase 1: texto (streaming), indicador de herramienta, errores.
/// Fase 2: opciones (botones), formulario dinámico, correcciones, resumen,
/// y el envío de las respuestas del usuario de vuelta al agente.
class AgenteTramitesProvider extends ChangeNotifier {
  final AgenteTramitesService _service;
  final _uuid = const Uuid();

  AgenteTramitesProvider(this._service);

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

  /// ID de la última solicitud creada (lo usa la Fase 4 para subir archivos).
  String? _ultimaSolicitudId;
  String? get ultimaSolicitudId => _ultimaSolicitudId;

  bool get estaVacio => _mensajes.isEmpty;

  // --- Acciones del usuario ---------------------------------------------

  /// Envía un mensaje de texto escrito por el usuario.
  Future<void> enviar(String texto) =>
      _enviarAlAgente(mensaje: texto.trim(), textoMostrado: texto.trim());

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
    List<Map<String, dynamic>> archivosListos,
  ) async {
    if (formulario.respondido || _enviando) return;
    formulario.respondido = true;
    formulario.errores = {};
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

          // Fase 4: subir archivos al backend tras crear la solicitud.
          case TipoEventoSSE.subirArchivos:
            debugPrint('[AGENTE] subir_archivos (Fase 4): ${evento.data}');
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
    notifyListeners();
  }
}
