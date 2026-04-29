// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tramite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RespuestaSolicitante _$RespuestaSolicitanteFromJson(
  Map<String, dynamic> json,
) => RespuestaSolicitante(
  nombreCampo: json['nombreCampo'] as String?,
  valor: json['valor'] as String?,
);

Map<String, dynamic> _$RespuestaSolicitanteToJson(
  RespuestaSolicitante instance,
) => <String, dynamic>{
  'nombreCampo': instance.nombreCampo,
  'valor': instance.valor,
};

RespuestaDepartamento _$RespuestaDepartamentoFromJson(
  Map<String, dynamic> json,
) => RespuestaDepartamento(
  departamentoId: json['departamentoId'] as String?,
  departamentoNombre: json['departamentoNombre'] as String?,
  elementId: json['elementId'] as String?,
  formularioId: json['formularioId'] as String?,
  funcionarioId: json['funcionarioId'] as String?,
  funcionarioNombre: json['funcionarioNombre'] as String?,
  funcionarioAsignadoId: json['funcionarioAsignadoId'] as String?,
  funcionarioAsignadoNombre: json['funcionarioAsignadoNombre'] as String?,
  fechaAsignacion: _parseFecha(json['fechaAsignacion']),
  accion: json['accion'] as String?,
  comentario: json['comentario'] as String?,
  fechaEntrada: _parseFecha(json['fechaEntrada']),
  fechaRespuesta: _parseFecha(json['fechaRespuesta']),
  respuestas:
      (json['respuestas'] as List<dynamic>?)
          ?.map((e) => RespuestaSolicitante.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$RespuestaDepartamentoToJson(
  RespuestaDepartamento instance,
) => <String, dynamic>{
  'departamentoId': instance.departamentoId,
  'departamentoNombre': instance.departamentoNombre,
  'elementId': instance.elementId,
  'formularioId': instance.formularioId,
  'funcionarioId': instance.funcionarioId,
  'funcionarioNombre': instance.funcionarioNombre,
  'funcionarioAsignadoId': instance.funcionarioAsignadoId,
  'funcionarioAsignadoNombre': instance.funcionarioAsignadoNombre,
  'fechaAsignacion': _fechaToJson(instance.fechaAsignacion),
  'accion': instance.accion,
  'comentario': instance.comentario,
  'fechaEntrada': _fechaToJson(instance.fechaEntrada),
  'fechaRespuesta': _fechaToJson(instance.fechaRespuesta),
  'respuestas': instance.respuestas.map((e) => e.toJson()).toList(),
};

Adjunto _$AdjuntoFromJson(Map<String, dynamic> json) => Adjunto(
  nombre: json['nombre'] as String?,
  url: json['url'] as String?,
  tipo: json['tipo'] as String?,
  fechaSubida: _parseFecha(json['fechaSubida']),
);

Map<String, dynamic> _$AdjuntoToJson(Adjunto instance) => <String, dynamic>{
  'nombre': instance.nombre,
  'url': instance.url,
  'tipo': instance.tipo,
  'fechaSubida': _fechaToJson(instance.fechaSubida),
};

SolicitudResumen _$SolicitudResumenFromJson(Map<String, dynamic> json) =>
    SolicitudResumen(
      id: json['id'] as String,
      tramiteId: json['tramiteId'] as String?,
      tramiteNombre: json['tramiteNombre'] as String?,
      solicitanteId: json['solicitanteId'] as String?,
      solicitanteNombre: json['solicitanteNombre'] as String?,
      estado: $enumDecode(
        _$EstadoSolicitudEnumMap,
        json['estado'],
        unknownValue: EstadoSolicitud.desconocido,
      ),
      departamentosActuales:
          (json['departamentosActuales'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      fechaCreacion: _parseFechaRequired(json['fechaCreacion']),
      fechaFinalizacion: _parseFecha(json['fechaFinalizacion']),
    );

Map<String, dynamic> _$SolicitudResumenToJson(SolicitudResumen instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tramiteId': instance.tramiteId,
      'tramiteNombre': instance.tramiteNombre,
      'solicitanteId': instance.solicitanteId,
      'solicitanteNombre': instance.solicitanteNombre,
      'estado': _$EstadoSolicitudEnumMap[instance.estado]!,
      'departamentosActuales': instance.departamentosActuales,
      'fechaCreacion': _fechaRequiredToJson(instance.fechaCreacion),
      'fechaFinalizacion': _fechaToJson(instance.fechaFinalizacion),
    };

const _$EstadoSolicitudEnumMap = {
  EstadoSolicitud.pendiente: 'PENDIENTE',
  EstadoSolicitud.enProceso: 'EN_PROCESO',
  EstadoSolicitud.aprobado: 'APROBADO',
  EstadoSolicitud.rechazado: 'RECHAZADO',
  EstadoSolicitud.cancelado: 'CANCELADO',
  EstadoSolicitud.desconocido: 'DESCONOCIDO',
};

SolicitudDetalle _$SolicitudDetalleFromJson(
  Map<String, dynamic> json,
) => SolicitudDetalle(
  id: json['id'] as String,
  tramiteId: json['tramiteId'] as String?,
  tramiteNombre: json['tramiteNombre'] as String?,
  solicitanteId: json['solicitanteId'] as String?,
  solicitanteNombre: json['solicitanteNombre'] as String?,
  estado: $enumDecode(
    _$EstadoSolicitudEnumMap,
    json['estado'],
    unknownValue: EstadoSolicitud.desconocido,
  ),
  departamentosActuales:
      (json['departamentosActuales'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  fechaCreacion: _parseFechaRequired(json['fechaCreacion']),
  fechaActualizacion: _parseFecha(json['fechaActualizacion']),
  fechaFinalizacion: _parseFecha(json['fechaFinalizacion']),
  respuestasSolicitante:
      (json['respuestasSolicitante'] as List<dynamic>?)
          ?.map((e) => RespuestaSolicitante.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  respuestasPorDepartamento:
      (json['respuestasPorDepartamento'] as List<dynamic>?)
          ?.map(
            (e) => RespuestaDepartamento.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
  adjuntos:
      (json['adjuntos'] as List<dynamic>?)
          ?.map((e) => Adjunto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$SolicitudDetalleToJson(SolicitudDetalle instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tramiteId': instance.tramiteId,
      'tramiteNombre': instance.tramiteNombre,
      'solicitanteId': instance.solicitanteId,
      'solicitanteNombre': instance.solicitanteNombre,
      'estado': _$EstadoSolicitudEnumMap[instance.estado]!,
      'departamentosActuales': instance.departamentosActuales,
      'fechaCreacion': _fechaRequiredToJson(instance.fechaCreacion),
      'fechaActualizacion': _fechaToJson(instance.fechaActualizacion),
      'fechaFinalizacion': _fechaToJson(instance.fechaFinalizacion),
      'respuestasSolicitante':
          instance.respuestasSolicitante.map((e) => e.toJson()).toList(),
      'respuestasPorDepartamento':
          instance.respuestasPorDepartamento.map((e) => e.toJson()).toList(),
      'adjuntos': instance.adjuntos.map((e) => e.toJson()).toList(),
    };

TramiteDisponible _$TramiteDisponibleFromJson(Map<String, dynamic> json) =>
    TramiteDisponible(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      formularioSolicitanteId: json['formularioSolicitanteId'] as String?,
      flujoTrabajoId: json['flujoTrabajoId'] as String?,
      requisitos:
          (json['requisitos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      activo: json['activo'] as bool,
      fechaCreacion: _parseFecha(json['fechaCreacion']),
    );

Map<String, dynamic> _$TramiteDisponibleToJson(TramiteDisponible instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'descripcion': instance.descripcion,
      'formularioSolicitanteId': instance.formularioSolicitanteId,
      'flujoTrabajoId': instance.flujoTrabajoId,
      'requisitos': instance.requisitos,
      'activo': instance.activo,
      'fechaCreacion': _fechaToJson(instance.fechaCreacion),
    };

CampoFormulario _$CampoFormularioFromJson(Map<String, dynamic> json) =>
    CampoFormulario(
      nombre: json['nombre'] as String,
      etiqueta: json['etiqueta'] as String?,
      tipo: $enumDecode(
        _$TipoCampoEnumMap,
        json['tipo'],
        unknownValue: TipoCampo.unknown,
      ),
      requerido: json['requerido'] as bool,
      opciones:
          (json['opciones'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$CampoFormularioToJson(CampoFormulario instance) =>
    <String, dynamic>{
      'nombre': instance.nombre,
      'etiqueta': instance.etiqueta,
      'tipo': _$TipoCampoEnumMap[instance.tipo]!,
      'requerido': instance.requerido,
      'opciones': instance.opciones,
    };

const _$TipoCampoEnumMap = {
  TipoCampo.text: 'TEXT',
  TipoCampo.number: 'NUMBER',
  TipoCampo.date: 'DATE',
  TipoCampo.select: 'SELECT',
  TipoCampo.checkbox: 'CHECKBOX',
  TipoCampo.file: 'FILE',
  TipoCampo.unknown: 'UNKNOWN',
};

FormularioTemplate _$FormularioTemplateFromJson(Map<String, dynamic> json) =>
    FormularioTemplate(
      id: json['id'] as String,
      titulo: json['titulo'] as String?,
      descripcion: json['descripcion'] as String?,
      activo: json['activo'] as bool,
      campos:
          (json['campos'] as List<dynamic>?)
              ?.map((e) => CampoFormulario.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$FormularioTemplateToJson(FormularioTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'titulo': instance.titulo,
      'descripcion': instance.descripcion,
      'activo': instance.activo,
      'campos': instance.campos.map((e) => e.toJson()).toList(),
    };
