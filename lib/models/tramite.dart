import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tramite.g.dart';

DateTime? _parseFecha(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

DateTime _parseFechaRequired(dynamic value) =>
    _parseFecha(value) ?? DateTime.fromMillisecondsSinceEpoch(0);

String? _fechaToJson(DateTime? dt) => dt?.toIso8601String();
String _fechaRequiredToJson(DateTime dt) => dt.toIso8601String();

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum EstadoSolicitud {
  @JsonValue('PENDIENTE')
  pendiente('Pendiente', Color(0xFF9E9E9E)),

  @JsonValue('EN_PROCESO')
  enProceso('En Proceso', Color(0xFF1976D2)),

  @JsonValue('APROBADO')
  aprobado('Aprobado', Color(0xFF388E3C)),

  @JsonValue('RECHAZADO')
  rechazado('Rechazado', Color(0xFFD32F2F)),

  @JsonValue('CANCELADO')
  cancelado('Cancelado', Color(0xFF616161)),

  @JsonValue('DESCONOCIDO')
  desconocido('Desconocido', Color(0xFF9E9E9E));

  final String label;
  final Color color;
  const EstadoSolicitud(this.label, this.color);
}

enum TipoCampo {
  @JsonValue('TEXT')
  text,
  @JsonValue('NUMBER')
  number,
  @JsonValue('DATE')
  date,
  @JsonValue('SELECT')
  select,
  @JsonValue('CHECKBOX')
  checkbox,
  @JsonValue('FILE')
  file,
  @JsonValue('UNKNOWN')
  unknown,
}

// ---------------------------------------------------------------------------
// Shared
// ---------------------------------------------------------------------------

@JsonSerializable()
class RespuestaSolicitante {
  @JsonKey(name: 'nombreCampo')
  final String? nombreCampo;
  final String? valor;

  const RespuestaSolicitante({this.nombreCampo, this.valor});

  factory RespuestaSolicitante.fromJson(Map<String, dynamic> json) =>
      _$RespuestaSolicitanteFromJson(json);
  Map<String, dynamic> toJson() => _$RespuestaSolicitanteToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RespuestaDepartamento {
  final String? departamentoId;
  final String? departamentoNombre;
  final String? elementId;
  final String? formularioId;
  final String? funcionarioId;
  final String? funcionarioNombre;
  final String? funcionarioAsignadoId;
  final String? funcionarioAsignadoNombre;

  @JsonKey(fromJson: _parseFecha, toJson: _fechaToJson)
  final DateTime? fechaAsignacion;

  final String? accion;

  /// Etiqueta legible de la acción (ej: "Continuar"/"Aprobado"), derivada del
  /// catálogo en el back. Para mostrar en el historial; `accion` queda intacto.
  final String? accionEtiqueta;

  final String? comentario;

  @JsonKey(fromJson: _parseFecha, toJson: _fechaToJson)
  final DateTime? fechaEntrada;

  @JsonKey(fromJson: _parseFecha, toJson: _fechaToJson)
  final DateTime? fechaRespuesta;

  @JsonKey(defaultValue: [])
  final List<RespuestaSolicitante> respuestas;

  const RespuestaDepartamento({
    this.departamentoId,
    this.departamentoNombre,
    this.elementId,
    this.formularioId,
    this.funcionarioId,
    this.funcionarioNombre,
    this.funcionarioAsignadoId,
    this.funcionarioAsignadoNombre,
    this.fechaAsignacion,
    this.accion,
    this.accionEtiqueta,
    this.comentario,
    this.fechaEntrada,
    this.fechaRespuesta,
    this.respuestas = const [],
  });

  factory RespuestaDepartamento.fromJson(Map<String, dynamic> json) =>
      _$RespuestaDepartamentoFromJson(json);
  Map<String, dynamic> toJson() => _$RespuestaDepartamentoToJson(this);
}

@JsonSerializable()
class Adjunto {
  final String? nombre;
  final String? url;
  final String? tipo;

  @JsonKey(name: 'fechaSubida', fromJson: _parseFecha, toJson: _fechaToJson)
  final DateTime? fechaSubida;

  const Adjunto({this.nombre, this.url, this.tipo, this.fechaSubida});

  factory Adjunto.fromJson(Map<String, dynamic> json) =>
      _$AdjuntoFromJson(json);
  Map<String, dynamic> toJson() => _$AdjuntoToJson(this);
}

// ---------------------------------------------------------------------------
// Solicitud — resumen (lista) y detalle
// ---------------------------------------------------------------------------

@JsonSerializable(explicitToJson: true)
class SolicitudResumen {
  final String id;
  final String? tramiteId;
  final String? tramiteNombre;
  final String? solicitanteId;
  final String? solicitanteNombre;

  @JsonKey(unknownEnumValue: EstadoSolicitud.desconocido)
  final EstadoSolicitud estado;

  @JsonKey(defaultValue: [])
  final List<String> departamentosActuales;

  @JsonKey(fromJson: _parseFechaRequired, toJson: _fechaRequiredToJson)
  final DateTime fechaCreacion;

  @JsonKey(fromJson: _parseFecha, toJson: _fechaToJson)
  final DateTime? fechaFinalizacion;

  const SolicitudResumen({
    required this.id,
    this.tramiteId,
    this.tramiteNombre,
    this.solicitanteId,
    this.solicitanteNombre,
    required this.estado,
    this.departamentosActuales = const [],
    required this.fechaCreacion,
    this.fechaFinalizacion,
  });

  factory SolicitudResumen.fromJson(Map<String, dynamic> json) =>
      _$SolicitudResumenFromJson(json);
  Map<String, dynamic> toJson() => _$SolicitudResumenToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SolicitudDetalle {
  final String id;
  final String? tramiteId;
  final String? tramiteNombre;
  final String? solicitanteId;
  final String? solicitanteNombre;

  @JsonKey(unknownEnumValue: EstadoSolicitud.desconocido)
  final EstadoSolicitud estado;

  @JsonKey(defaultValue: [])
  final List<String> departamentosActuales;

  @JsonKey(fromJson: _parseFechaRequired, toJson: _fechaRequiredToJson)
  final DateTime fechaCreacion;

  @JsonKey(fromJson: _parseFecha, toJson: _fechaToJson)
  final DateTime? fechaActualizacion;

  @JsonKey(fromJson: _parseFecha, toJson: _fechaToJson)
  final DateTime? fechaFinalizacion;

  @JsonKey(defaultValue: [])
  final List<RespuestaSolicitante> respuestasSolicitante;

  @JsonKey(defaultValue: [])
  final List<RespuestaDepartamento> respuestasPorDepartamento;

  @JsonKey(defaultValue: [])
  final List<Adjunto> adjuntos;

  const SolicitudDetalle({
    required this.id,
    this.tramiteId,
    this.tramiteNombre,
    this.solicitanteId,
    this.solicitanteNombre,
    required this.estado,
    this.departamentosActuales = const [],
    required this.fechaCreacion,
    this.fechaActualizacion,
    this.fechaFinalizacion,
    this.respuestasSolicitante = const [],
    this.respuestasPorDepartamento = const [],
    this.adjuntos = const [],
  });

  factory SolicitudDetalle.fromJson(Map<String, dynamic> json) =>
      _$SolicitudDetalleFromJson(json);
  Map<String, dynamic> toJson() => _$SolicitudDetalleToJson(this);
}

// ---------------------------------------------------------------------------
// Catálogo de trámites disponibles
// ---------------------------------------------------------------------------

@JsonSerializable()
class TramiteDisponible {
  final String id;
  final String nombre;
  final String? descripcion;
  final String? formularioSolicitanteId;
  final String? flujoTrabajoId;

  @JsonKey(defaultValue: [])
  final List<String> requisitos;

  /// Palabras clave para el asistente offline (matcheo). Si el back no las
  /// manda, queda vacío y el buscador usa nombre/descripción/requisitos.
  @JsonKey(defaultValue: [])
  final List<String> etiquetas;

  final bool activo;

  @JsonKey(fromJson: _parseFecha, toJson: _fechaToJson)
  final DateTime? fechaCreacion;

  const TramiteDisponible({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.formularioSolicitanteId,
    this.flujoTrabajoId,
    this.requisitos = const [],
    this.etiquetas = const [],
    required this.activo,
    this.fechaCreacion,
  });

  factory TramiteDisponible.fromJson(Map<String, dynamic> json) =>
      _$TramiteDisponibleFromJson(json);
  Map<String, dynamic> toJson() => _$TramiteDisponibleToJson(this);
}

// ---------------------------------------------------------------------------
// Formulario dinámico
// ---------------------------------------------------------------------------

@JsonSerializable()
class CampoFormulario {
  final String nombre;
  final String? etiqueta;

  @JsonKey(unknownEnumValue: TipoCampo.unknown)
  final TipoCampo tipo;

  final bool requerido;

  @JsonKey(defaultValue: [])
  final List<String> opciones;

  const CampoFormulario({
    required this.nombre,
    this.etiqueta,
    required this.tipo,
    required this.requerido,
    this.opciones = const [],
  });

  factory CampoFormulario.fromJson(Map<String, dynamic> json) =>
      _$CampoFormularioFromJson(json);
  Map<String, dynamic> toJson() => _$CampoFormularioToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FormularioTemplate {
  final String id;
  final String? titulo;
  final String? descripcion;
  final bool activo;

  @JsonKey(defaultValue: [])
  final List<CampoFormulario> campos;

  const FormularioTemplate({
    required this.id,
    this.titulo,
    this.descripcion,
    required this.activo,
    this.campos = const [],
  });

  factory FormularioTemplate.fromJson(Map<String, dynamic> json) =>
      _$FormularioTemplateFromJson(json);
  Map<String, dynamic> toJson() => _$FormularioTemplateToJson(this);
}
