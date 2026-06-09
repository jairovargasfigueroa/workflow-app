import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tramites_app/models/evento_sse.dart';
import 'package:tramites_app/services/api_service.dart';

/// Cliente del agente de trámites.
///
/// Habla SOLO con Spring (la única URL del back); FastAPI/Gemini quedan ocultos
/// detrás. Reutiliza el [Dio] del [ApiService] para compartir baseUrl y el
/// header `Authorization` ya inyectado tras el login.
class AgenteTramitesService {
  final ApiService _apiService;

  AgenteTramitesService(this._apiService);

  Dio get _dio => _apiService.dio;

  /// Manda un mensaje al agente y emite los eventos SSE a medida que llegan.
  ///
  /// SSE con `ResponseType.stream` (EventSource nativo no sirve: no soporta
  /// headers personalizados como Authorization).
  ///
  /// [datos] y [archivosListos] se usan en fases posteriores cuando el usuario
  /// completa un formulario o marca archivos como listos.
  Stream<EventoSSE> enviarMensaje({
    required String? sesionId,
    required String clientMessageId,
    required String mensaje,
    Map<String, dynamic>? datos,
    List<Map<String, dynamic>>? archivosListos,
  }) async* {
    final body = <String, dynamic>{
      'sesionId': sesionId, // null si es sesión nueva (contrato v1.0)
      'clientMessageId': clientMessageId,
      'mensaje': mensaje,
      if (datos != null) 'datos': datos,
      if (archivosListos != null) 'archivosListos': archivosListos,
    };

    debugPrint('[AGENTE] POST /api/agente-tramites/chat sesion=$sesionId');

    final Response<ResponseBody> response;
    try {
      response = await _dio.post<ResponseBody>(
        '/api/agente-tramites/chat',
        data: body,
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
        ),
      );
    } on DioException catch (e) {
      throw Exception(_mensajeError(e));
    }

    final stream = response.data?.stream;
    if (stream == null) {
      throw Exception('El servidor no devolvió un stream.');
    }

    // Buffer acumulador: los eventos SSE se separan por una línea en blanco
    // (\n\n) y un evento puede quedar partido entre dos chunks de red.
    var buffer = '';
    await for (final chunk in stream) {
      buffer += utf8.decode(chunk, allowMalformed: true).replaceAll('\r\n', '\n');

      var sep = buffer.indexOf('\n\n');
      while (sep != -1) {
        final bloque = buffer.substring(0, sep);
        buffer = buffer.substring(sep + 2);
        final evento = _parseBloque(bloque);
        if (evento != null) yield evento;
        sep = buffer.indexOf('\n\n');
      }
    }

    // Último bloque sin salto final.
    final evento = _parseBloque(buffer);
    if (evento != null) yield evento;
  }

  /// Recupera una sesión activa para reanudar la conversación (usado en Fase 5).
  Future<Map<String, dynamic>> recuperarSesion(String sesionId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/agente-tramites/sesion/$sesionId',
      );
      return response.data ?? <String, dynamic>{};
    } on DioException catch (e) {
      throw Exception(_mensajeError(e));
    }
  }

  /// Parsea un bloque SSE (una o varias líneas `data:`) a un [EventoSSE].
  /// Devuelve null si el bloque está vacío, es un comentario o no es JSON.
  EventoSSE? _parseBloque(String bloque) {
    final dataLines = <String>[];
    for (final line in const LineSplitter().convert(bloque)) {
      if (line.startsWith('data:')) {
        dataLines.add(line.substring(5).trimLeft());
      }
    }
    if (dataLines.isEmpty) return null;

    final payload = dataLines.join('\n').trim();
    if (payload.isEmpty || payload == '[DONE]') return null;

    try {
      final json = jsonDecode(payload) as Map<String, dynamic>;
      return EventoSSE.fromJson(json);
    } catch (e) {
      debugPrint('[AGENTE] No se pudo parsear bloque SSE: $e | "$payload"');
      return null;
    }
  }

  String _mensajeError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Tiempo de espera agotado. Verifica tu conexión.';
      case DioExceptionType.connectionError:
        return 'No se pudo conectar al servidor.';
      case DioExceptionType.badResponse:
        final codigo = e.response?.statusCode;
        return 'Error del servidor (código $codigo).';
      default:
        return e.message ?? 'Error desconocido.';
    }
  }
}
