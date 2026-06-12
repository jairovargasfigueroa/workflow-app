// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SolicitudesTable extends Solicitudes
    with TableInfo<$SolicitudesTable, SolicitudRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SolicitudesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tramiteIdMeta = const VerificationMeta(
    'tramiteId',
  );
  @override
  late final GeneratedColumn<String> tramiteId = GeneratedColumn<String>(
    'tramite_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tramiteNombreMeta = const VerificationMeta(
    'tramiteNombre',
  );
  @override
  late final GeneratedColumn<String> tramiteNombre = GeneratedColumn<String>(
    'tramite_nombre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaCreacionMeta = const VerificationMeta(
    'fechaCreacion',
  );
  @override
  late final GeneratedColumn<DateTime> fechaCreacion =
      GeneratedColumn<DateTime>(
        'fecha_creacion',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fechaFinalizacionMeta = const VerificationMeta(
    'fechaFinalizacion',
  );
  @override
  late final GeneratedColumn<DateTime> fechaFinalizacion =
      GeneratedColumn<DateTime>(
        'fecha_finalizacion',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _detalleJsonMeta = const VerificationMeta(
    'detalleJson',
  );
  @override
  late final GeneratedColumn<String> detalleJson = GeneratedColumn<String>(
    'detalle_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendienteSyncMeta = const VerificationMeta(
    'pendienteSync',
  );
  @override
  late final GeneratedColumn<bool> pendienteSync = GeneratedColumn<bool>(
    'pendiente_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pendiente_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadoEn =
      GeneratedColumn<DateTime>(
        'actualizado_en',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tramiteId,
    tramiteNombre,
    estado,
    fechaCreacion,
    fechaFinalizacion,
    detalleJson,
    pendienteSync,
    clientId,
    syncError,
    actualizadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'solicitudes';
  @override
  VerificationContext validateIntegrity(
    Insertable<SolicitudRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tramite_id')) {
      context.handle(
        _tramiteIdMeta,
        tramiteId.isAcceptableOrUnknown(data['tramite_id']!, _tramiteIdMeta),
      );
    }
    if (data.containsKey('tramite_nombre')) {
      context.handle(
        _tramiteNombreMeta,
        tramiteNombre.isAcceptableOrUnknown(
          data['tramite_nombre']!,
          _tramiteNombreMeta,
        ),
      );
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    }
    if (data.containsKey('fecha_creacion')) {
      context.handle(
        _fechaCreacionMeta,
        fechaCreacion.isAcceptableOrUnknown(
          data['fecha_creacion']!,
          _fechaCreacionMeta,
        ),
      );
    }
    if (data.containsKey('fecha_finalizacion')) {
      context.handle(
        _fechaFinalizacionMeta,
        fechaFinalizacion.isAcceptableOrUnknown(
          data['fecha_finalizacion']!,
          _fechaFinalizacionMeta,
        ),
      );
    }
    if (data.containsKey('detalle_json')) {
      context.handle(
        _detalleJsonMeta,
        detalleJson.isAcceptableOrUnknown(
          data['detalle_json']!,
          _detalleJsonMeta,
        ),
      );
    }
    if (data.containsKey('pendiente_sync')) {
      context.handle(
        _pendienteSyncMeta,
        pendienteSync.isAcceptableOrUnknown(
          data['pendiente_sync']!,
          _pendienteSyncMeta,
        ),
      );
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SolicitudRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SolicitudRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      tramiteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tramite_id'],
      ),
      tramiteNombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tramite_nombre'],
      ),
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      ),
      fechaCreacion: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_creacion'],
      ),
      fechaFinalizacion: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_finalizacion'],
      ),
      detalleJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detalle_json'],
      ),
      pendienteSync:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}pendiente_sync'],
          )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      ),
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizado_en'],
      ),
    );
  }

  @override
  $SolicitudesTable createAlias(String alias) {
    return $SolicitudesTable(attachedDatabase, alias);
  }
}

class SolicitudRow extends DataClass implements Insertable<SolicitudRow> {
  final String id;
  final String? tramiteId;
  final String? tramiteNombre;
  final String? estado;
  final DateTime? fechaCreacion;
  final DateTime? fechaFinalizacion;

  /// JSON crudo del detalle completo (respuestas, historial por depto, etc.).
  final String? detalleJson;

  /// true si es una solicitud creada offline que todavía no se sincronizó.
  final bool pendienteSync;

  /// clientId (UUID) de la operación que la creó (para enlazarla con el Outbox).
  final String? clientId;

  /// Motivo del fallo de sincronización (null = sin error). Si está seteado,
  /// la solicitud quedó en estado "Error" y no se reintenta sola.
  final String? syncError;
  final DateTime? actualizadoEn;
  const SolicitudRow({
    required this.id,
    this.tramiteId,
    this.tramiteNombre,
    this.estado,
    this.fechaCreacion,
    this.fechaFinalizacion,
    this.detalleJson,
    required this.pendienteSync,
    this.clientId,
    this.syncError,
    this.actualizadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || tramiteId != null) {
      map['tramite_id'] = Variable<String>(tramiteId);
    }
    if (!nullToAbsent || tramiteNombre != null) {
      map['tramite_nombre'] = Variable<String>(tramiteNombre);
    }
    if (!nullToAbsent || estado != null) {
      map['estado'] = Variable<String>(estado);
    }
    if (!nullToAbsent || fechaCreacion != null) {
      map['fecha_creacion'] = Variable<DateTime>(fechaCreacion);
    }
    if (!nullToAbsent || fechaFinalizacion != null) {
      map['fecha_finalizacion'] = Variable<DateTime>(fechaFinalizacion);
    }
    if (!nullToAbsent || detalleJson != null) {
      map['detalle_json'] = Variable<String>(detalleJson);
    }
    map['pendiente_sync'] = Variable<bool>(pendienteSync);
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    if (!nullToAbsent || actualizadoEn != null) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn);
    }
    return map;
  }

  SolicitudesCompanion toCompanion(bool nullToAbsent) {
    return SolicitudesCompanion(
      id: Value(id),
      tramiteId:
          tramiteId == null && nullToAbsent
              ? const Value.absent()
              : Value(tramiteId),
      tramiteNombre:
          tramiteNombre == null && nullToAbsent
              ? const Value.absent()
              : Value(tramiteNombre),
      estado:
          estado == null && nullToAbsent ? const Value.absent() : Value(estado),
      fechaCreacion:
          fechaCreacion == null && nullToAbsent
              ? const Value.absent()
              : Value(fechaCreacion),
      fechaFinalizacion:
          fechaFinalizacion == null && nullToAbsent
              ? const Value.absent()
              : Value(fechaFinalizacion),
      detalleJson:
          detalleJson == null && nullToAbsent
              ? const Value.absent()
              : Value(detalleJson),
      pendienteSync: Value(pendienteSync),
      clientId:
          clientId == null && nullToAbsent
              ? const Value.absent()
              : Value(clientId),
      syncError:
          syncError == null && nullToAbsent
              ? const Value.absent()
              : Value(syncError),
      actualizadoEn:
          actualizadoEn == null && nullToAbsent
              ? const Value.absent()
              : Value(actualizadoEn),
    );
  }

  factory SolicitudRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SolicitudRow(
      id: serializer.fromJson<String>(json['id']),
      tramiteId: serializer.fromJson<String?>(json['tramiteId']),
      tramiteNombre: serializer.fromJson<String?>(json['tramiteNombre']),
      estado: serializer.fromJson<String?>(json['estado']),
      fechaCreacion: serializer.fromJson<DateTime?>(json['fechaCreacion']),
      fechaFinalizacion: serializer.fromJson<DateTime?>(
        json['fechaFinalizacion'],
      ),
      detalleJson: serializer.fromJson<String?>(json['detalleJson']),
      pendienteSync: serializer.fromJson<bool>(json['pendienteSync']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      syncError: serializer.fromJson<String?>(json['syncError']),
      actualizadoEn: serializer.fromJson<DateTime?>(json['actualizadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tramiteId': serializer.toJson<String?>(tramiteId),
      'tramiteNombre': serializer.toJson<String?>(tramiteNombre),
      'estado': serializer.toJson<String?>(estado),
      'fechaCreacion': serializer.toJson<DateTime?>(fechaCreacion),
      'fechaFinalizacion': serializer.toJson<DateTime?>(fechaFinalizacion),
      'detalleJson': serializer.toJson<String?>(detalleJson),
      'pendienteSync': serializer.toJson<bool>(pendienteSync),
      'clientId': serializer.toJson<String?>(clientId),
      'syncError': serializer.toJson<String?>(syncError),
      'actualizadoEn': serializer.toJson<DateTime?>(actualizadoEn),
    };
  }

  SolicitudRow copyWith({
    String? id,
    Value<String?> tramiteId = const Value.absent(),
    Value<String?> tramiteNombre = const Value.absent(),
    Value<String?> estado = const Value.absent(),
    Value<DateTime?> fechaCreacion = const Value.absent(),
    Value<DateTime?> fechaFinalizacion = const Value.absent(),
    Value<String?> detalleJson = const Value.absent(),
    bool? pendienteSync,
    Value<String?> clientId = const Value.absent(),
    Value<String?> syncError = const Value.absent(),
    Value<DateTime?> actualizadoEn = const Value.absent(),
  }) => SolicitudRow(
    id: id ?? this.id,
    tramiteId: tramiteId.present ? tramiteId.value : this.tramiteId,
    tramiteNombre:
        tramiteNombre.present ? tramiteNombre.value : this.tramiteNombre,
    estado: estado.present ? estado.value : this.estado,
    fechaCreacion:
        fechaCreacion.present ? fechaCreacion.value : this.fechaCreacion,
    fechaFinalizacion:
        fechaFinalizacion.present
            ? fechaFinalizacion.value
            : this.fechaFinalizacion,
    detalleJson: detalleJson.present ? detalleJson.value : this.detalleJson,
    pendienteSync: pendienteSync ?? this.pendienteSync,
    clientId: clientId.present ? clientId.value : this.clientId,
    syncError: syncError.present ? syncError.value : this.syncError,
    actualizadoEn:
        actualizadoEn.present ? actualizadoEn.value : this.actualizadoEn,
  );
  SolicitudRow copyWithCompanion(SolicitudesCompanion data) {
    return SolicitudRow(
      id: data.id.present ? data.id.value : this.id,
      tramiteId: data.tramiteId.present ? data.tramiteId.value : this.tramiteId,
      tramiteNombre:
          data.tramiteNombre.present
              ? data.tramiteNombre.value
              : this.tramiteNombre,
      estado: data.estado.present ? data.estado.value : this.estado,
      fechaCreacion:
          data.fechaCreacion.present
              ? data.fechaCreacion.value
              : this.fechaCreacion,
      fechaFinalizacion:
          data.fechaFinalizacion.present
              ? data.fechaFinalizacion.value
              : this.fechaFinalizacion,
      detalleJson:
          data.detalleJson.present ? data.detalleJson.value : this.detalleJson,
      pendienteSync:
          data.pendienteSync.present
              ? data.pendienteSync.value
              : this.pendienteSync,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
      actualizadoEn:
          data.actualizadoEn.present
              ? data.actualizadoEn.value
              : this.actualizadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SolicitudRow(')
          ..write('id: $id, ')
          ..write('tramiteId: $tramiteId, ')
          ..write('tramiteNombre: $tramiteNombre, ')
          ..write('estado: $estado, ')
          ..write('fechaCreacion: $fechaCreacion, ')
          ..write('fechaFinalizacion: $fechaFinalizacion, ')
          ..write('detalleJson: $detalleJson, ')
          ..write('pendienteSync: $pendienteSync, ')
          ..write('clientId: $clientId, ')
          ..write('syncError: $syncError, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tramiteId,
    tramiteNombre,
    estado,
    fechaCreacion,
    fechaFinalizacion,
    detalleJson,
    pendienteSync,
    clientId,
    syncError,
    actualizadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolicitudRow &&
          other.id == this.id &&
          other.tramiteId == this.tramiteId &&
          other.tramiteNombre == this.tramiteNombre &&
          other.estado == this.estado &&
          other.fechaCreacion == this.fechaCreacion &&
          other.fechaFinalizacion == this.fechaFinalizacion &&
          other.detalleJson == this.detalleJson &&
          other.pendienteSync == this.pendienteSync &&
          other.clientId == this.clientId &&
          other.syncError == this.syncError &&
          other.actualizadoEn == this.actualizadoEn);
}

class SolicitudesCompanion extends UpdateCompanion<SolicitudRow> {
  final Value<String> id;
  final Value<String?> tramiteId;
  final Value<String?> tramiteNombre;
  final Value<String?> estado;
  final Value<DateTime?> fechaCreacion;
  final Value<DateTime?> fechaFinalizacion;
  final Value<String?> detalleJson;
  final Value<bool> pendienteSync;
  final Value<String?> clientId;
  final Value<String?> syncError;
  final Value<DateTime?> actualizadoEn;
  final Value<int> rowid;
  const SolicitudesCompanion({
    this.id = const Value.absent(),
    this.tramiteId = const Value.absent(),
    this.tramiteNombre = const Value.absent(),
    this.estado = const Value.absent(),
    this.fechaCreacion = const Value.absent(),
    this.fechaFinalizacion = const Value.absent(),
    this.detalleJson = const Value.absent(),
    this.pendienteSync = const Value.absent(),
    this.clientId = const Value.absent(),
    this.syncError = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SolicitudesCompanion.insert({
    required String id,
    this.tramiteId = const Value.absent(),
    this.tramiteNombre = const Value.absent(),
    this.estado = const Value.absent(),
    this.fechaCreacion = const Value.absent(),
    this.fechaFinalizacion = const Value.absent(),
    this.detalleJson = const Value.absent(),
    this.pendienteSync = const Value.absent(),
    this.clientId = const Value.absent(),
    this.syncError = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<SolicitudRow> custom({
    Expression<String>? id,
    Expression<String>? tramiteId,
    Expression<String>? tramiteNombre,
    Expression<String>? estado,
    Expression<DateTime>? fechaCreacion,
    Expression<DateTime>? fechaFinalizacion,
    Expression<String>? detalleJson,
    Expression<bool>? pendienteSync,
    Expression<String>? clientId,
    Expression<String>? syncError,
    Expression<DateTime>? actualizadoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tramiteId != null) 'tramite_id': tramiteId,
      if (tramiteNombre != null) 'tramite_nombre': tramiteNombre,
      if (estado != null) 'estado': estado,
      if (fechaCreacion != null) 'fecha_creacion': fechaCreacion,
      if (fechaFinalizacion != null) 'fecha_finalizacion': fechaFinalizacion,
      if (detalleJson != null) 'detalle_json': detalleJson,
      if (pendienteSync != null) 'pendiente_sync': pendienteSync,
      if (clientId != null) 'client_id': clientId,
      if (syncError != null) 'sync_error': syncError,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SolicitudesCompanion copyWith({
    Value<String>? id,
    Value<String?>? tramiteId,
    Value<String?>? tramiteNombre,
    Value<String?>? estado,
    Value<DateTime?>? fechaCreacion,
    Value<DateTime?>? fechaFinalizacion,
    Value<String?>? detalleJson,
    Value<bool>? pendienteSync,
    Value<String?>? clientId,
    Value<String?>? syncError,
    Value<DateTime?>? actualizadoEn,
    Value<int>? rowid,
  }) {
    return SolicitudesCompanion(
      id: id ?? this.id,
      tramiteId: tramiteId ?? this.tramiteId,
      tramiteNombre: tramiteNombre ?? this.tramiteNombre,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaFinalizacion: fechaFinalizacion ?? this.fechaFinalizacion,
      detalleJson: detalleJson ?? this.detalleJson,
      pendienteSync: pendienteSync ?? this.pendienteSync,
      clientId: clientId ?? this.clientId,
      syncError: syncError ?? this.syncError,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tramiteId.present) {
      map['tramite_id'] = Variable<String>(tramiteId.value);
    }
    if (tramiteNombre.present) {
      map['tramite_nombre'] = Variable<String>(tramiteNombre.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (fechaCreacion.present) {
      map['fecha_creacion'] = Variable<DateTime>(fechaCreacion.value);
    }
    if (fechaFinalizacion.present) {
      map['fecha_finalizacion'] = Variable<DateTime>(fechaFinalizacion.value);
    }
    if (detalleJson.present) {
      map['detalle_json'] = Variable<String>(detalleJson.value);
    }
    if (pendienteSync.present) {
      map['pendiente_sync'] = Variable<bool>(pendienteSync.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SolicitudesCompanion(')
          ..write('id: $id, ')
          ..write('tramiteId: $tramiteId, ')
          ..write('tramiteNombre: $tramiteNombre, ')
          ..write('estado: $estado, ')
          ..write('fechaCreacion: $fechaCreacion, ')
          ..write('fechaFinalizacion: $fechaFinalizacion, ')
          ..write('detalleJson: $detalleJson, ')
          ..write('pendienteSync: $pendienteSync, ')
          ..write('clientId: $clientId, ')
          ..write('syncError: $syncError, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TramitesTable extends Tramites
    with TableInfo<$TramitesTable, TramiteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TramitesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _formularioSolicitanteIdMeta =
      const VerificationMeta('formularioSolicitanteId');
  @override
  late final GeneratedColumn<String> formularioSolicitanteId =
      GeneratedColumn<String>(
        'formulario_solicitante_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadoEn =
      GeneratedColumn<DateTime>(
        'actualizado_en',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    descripcion,
    formularioSolicitanteId,
    activo,
    json,
    actualizadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tramites';
  @override
  VerificationContext validateIntegrity(
    Insertable<TramiteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    }
    if (data.containsKey('formulario_solicitante_id')) {
      context.handle(
        _formularioSolicitanteIdMeta,
        formularioSolicitanteId.isAcceptableOrUnknown(
          data['formulario_solicitante_id']!,
          _formularioSolicitanteIdMeta,
        ),
      );
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TramiteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TramiteRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      ),
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      ),
      formularioSolicitanteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}formulario_solicitante_id'],
      ),
      activo:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}activo'],
          )!,
      json:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}json'],
          )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizado_en'],
      ),
    );
  }

  @override
  $TramitesTable createAlias(String alias) {
    return $TramitesTable(attachedDatabase, alias);
  }
}

class TramiteRow extends DataClass implements Insertable<TramiteRow> {
  final String id;
  final String? nombre;
  final String? descripcion;
  final String? formularioSolicitanteId;
  final bool activo;

  /// JSON crudo del TramiteDisponible (requisitos, etc.).
  final String json;
  final DateTime? actualizadoEn;
  const TramiteRow({
    required this.id,
    this.nombre,
    this.descripcion,
    this.formularioSolicitanteId,
    required this.activo,
    required this.json,
    this.actualizadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || nombre != null) {
      map['nombre'] = Variable<String>(nombre);
    }
    if (!nullToAbsent || descripcion != null) {
      map['descripcion'] = Variable<String>(descripcion);
    }
    if (!nullToAbsent || formularioSolicitanteId != null) {
      map['formulario_solicitante_id'] = Variable<String>(
        formularioSolicitanteId,
      );
    }
    map['activo'] = Variable<bool>(activo);
    map['json'] = Variable<String>(json);
    if (!nullToAbsent || actualizadoEn != null) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn);
    }
    return map;
  }

  TramitesCompanion toCompanion(bool nullToAbsent) {
    return TramitesCompanion(
      id: Value(id),
      nombre:
          nombre == null && nullToAbsent ? const Value.absent() : Value(nombre),
      descripcion:
          descripcion == null && nullToAbsent
              ? const Value.absent()
              : Value(descripcion),
      formularioSolicitanteId:
          formularioSolicitanteId == null && nullToAbsent
              ? const Value.absent()
              : Value(formularioSolicitanteId),
      activo: Value(activo),
      json: Value(json),
      actualizadoEn:
          actualizadoEn == null && nullToAbsent
              ? const Value.absent()
              : Value(actualizadoEn),
    );
  }

  factory TramiteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TramiteRow(
      id: serializer.fromJson<String>(json['id']),
      nombre: serializer.fromJson<String?>(json['nombre']),
      descripcion: serializer.fromJson<String?>(json['descripcion']),
      formularioSolicitanteId: serializer.fromJson<String?>(
        json['formularioSolicitanteId'],
      ),
      activo: serializer.fromJson<bool>(json['activo']),
      json: serializer.fromJson<String>(json['json']),
      actualizadoEn: serializer.fromJson<DateTime?>(json['actualizadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nombre': serializer.toJson<String?>(nombre),
      'descripcion': serializer.toJson<String?>(descripcion),
      'formularioSolicitanteId': serializer.toJson<String?>(
        formularioSolicitanteId,
      ),
      'activo': serializer.toJson<bool>(activo),
      'json': serializer.toJson<String>(json),
      'actualizadoEn': serializer.toJson<DateTime?>(actualizadoEn),
    };
  }

  TramiteRow copyWith({
    String? id,
    Value<String?> nombre = const Value.absent(),
    Value<String?> descripcion = const Value.absent(),
    Value<String?> formularioSolicitanteId = const Value.absent(),
    bool? activo,
    String? json,
    Value<DateTime?> actualizadoEn = const Value.absent(),
  }) => TramiteRow(
    id: id ?? this.id,
    nombre: nombre.present ? nombre.value : this.nombre,
    descripcion: descripcion.present ? descripcion.value : this.descripcion,
    formularioSolicitanteId:
        formularioSolicitanteId.present
            ? formularioSolicitanteId.value
            : this.formularioSolicitanteId,
    activo: activo ?? this.activo,
    json: json ?? this.json,
    actualizadoEn:
        actualizadoEn.present ? actualizadoEn.value : this.actualizadoEn,
  );
  TramiteRow copyWithCompanion(TramitesCompanion data) {
    return TramiteRow(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      descripcion:
          data.descripcion.present ? data.descripcion.value : this.descripcion,
      formularioSolicitanteId:
          data.formularioSolicitanteId.present
              ? data.formularioSolicitanteId.value
              : this.formularioSolicitanteId,
      activo: data.activo.present ? data.activo.value : this.activo,
      json: data.json.present ? data.json.value : this.json,
      actualizadoEn:
          data.actualizadoEn.present
              ? data.actualizadoEn.value
              : this.actualizadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TramiteRow(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion, ')
          ..write('formularioSolicitanteId: $formularioSolicitanteId, ')
          ..write('activo: $activo, ')
          ..write('json: $json, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nombre,
    descripcion,
    formularioSolicitanteId,
    activo,
    json,
    actualizadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TramiteRow &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.descripcion == this.descripcion &&
          other.formularioSolicitanteId == this.formularioSolicitanteId &&
          other.activo == this.activo &&
          other.json == this.json &&
          other.actualizadoEn == this.actualizadoEn);
}

class TramitesCompanion extends UpdateCompanion<TramiteRow> {
  final Value<String> id;
  final Value<String?> nombre;
  final Value<String?> descripcion;
  final Value<String?> formularioSolicitanteId;
  final Value<bool> activo;
  final Value<String> json;
  final Value<DateTime?> actualizadoEn;
  final Value<int> rowid;
  const TramitesCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.formularioSolicitanteId = const Value.absent(),
    this.activo = const Value.absent(),
    this.json = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TramitesCompanion.insert({
    required String id,
    this.nombre = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.formularioSolicitanteId = const Value.absent(),
    this.activo = const Value.absent(),
    required String json,
    this.actualizadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       json = Value(json);
  static Insertable<TramiteRow> custom({
    Expression<String>? id,
    Expression<String>? nombre,
    Expression<String>? descripcion,
    Expression<String>? formularioSolicitanteId,
    Expression<bool>? activo,
    Expression<String>? json,
    Expression<DateTime>? actualizadoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      if (formularioSolicitanteId != null)
        'formulario_solicitante_id': formularioSolicitanteId,
      if (activo != null) 'activo': activo,
      if (json != null) 'json': json,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TramitesCompanion copyWith({
    Value<String>? id,
    Value<String?>? nombre,
    Value<String?>? descripcion,
    Value<String?>? formularioSolicitanteId,
    Value<bool>? activo,
    Value<String>? json,
    Value<DateTime?>? actualizadoEn,
    Value<int>? rowid,
  }) {
    return TramitesCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      formularioSolicitanteId:
          formularioSolicitanteId ?? this.formularioSolicitanteId,
      activo: activo ?? this.activo,
      json: json ?? this.json,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (formularioSolicitanteId.present) {
      map['formulario_solicitante_id'] = Variable<String>(
        formularioSolicitanteId.value,
      );
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TramitesCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion, ')
          ..write('formularioSolicitanteId: $formularioSolicitanteId, ')
          ..write('activo: $activo, ')
          ..write('json: $json, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FormulariosCacheTable extends FormulariosCache
    with TableInfo<$FormulariosCacheTable, FormularioCacheRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FormulariosCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadoEn =
      GeneratedColumn<DateTime>(
        'actualizado_en',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [id, json, actualizadoEn];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'formularios_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<FormularioCacheRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FormularioCacheRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FormularioCacheRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      json:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}json'],
          )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizado_en'],
      ),
    );
  }

  @override
  $FormulariosCacheTable createAlias(String alias) {
    return $FormulariosCacheTable(attachedDatabase, alias);
  }
}

class FormularioCacheRow extends DataClass
    implements Insertable<FormularioCacheRow> {
  final String id;
  final String json;
  final DateTime? actualizadoEn;
  const FormularioCacheRow({
    required this.id,
    required this.json,
    this.actualizadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['json'] = Variable<String>(json);
    if (!nullToAbsent || actualizadoEn != null) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn);
    }
    return map;
  }

  FormulariosCacheCompanion toCompanion(bool nullToAbsent) {
    return FormulariosCacheCompanion(
      id: Value(id),
      json: Value(json),
      actualizadoEn:
          actualizadoEn == null && nullToAbsent
              ? const Value.absent()
              : Value(actualizadoEn),
    );
  }

  factory FormularioCacheRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FormularioCacheRow(
      id: serializer.fromJson<String>(json['id']),
      json: serializer.fromJson<String>(json['json']),
      actualizadoEn: serializer.fromJson<DateTime?>(json['actualizadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'json': serializer.toJson<String>(json),
      'actualizadoEn': serializer.toJson<DateTime?>(actualizadoEn),
    };
  }

  FormularioCacheRow copyWith({
    String? id,
    String? json,
    Value<DateTime?> actualizadoEn = const Value.absent(),
  }) => FormularioCacheRow(
    id: id ?? this.id,
    json: json ?? this.json,
    actualizadoEn:
        actualizadoEn.present ? actualizadoEn.value : this.actualizadoEn,
  );
  FormularioCacheRow copyWithCompanion(FormulariosCacheCompanion data) {
    return FormularioCacheRow(
      id: data.id.present ? data.id.value : this.id,
      json: data.json.present ? data.json.value : this.json,
      actualizadoEn:
          data.actualizadoEn.present
              ? data.actualizadoEn.value
              : this.actualizadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FormularioCacheRow(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, json, actualizadoEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FormularioCacheRow &&
          other.id == this.id &&
          other.json == this.json &&
          other.actualizadoEn == this.actualizadoEn);
}

class FormulariosCacheCompanion extends UpdateCompanion<FormularioCacheRow> {
  final Value<String> id;
  final Value<String> json;
  final Value<DateTime?> actualizadoEn;
  final Value<int> rowid;
  const FormulariosCacheCompanion({
    this.id = const Value.absent(),
    this.json = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FormulariosCacheCompanion.insert({
    required String id,
    required String json,
    this.actualizadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       json = Value(json);
  static Insertable<FormularioCacheRow> custom({
    Expression<String>? id,
    Expression<String>? json,
    Expression<DateTime>? actualizadoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (json != null) 'json': json,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FormulariosCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? json,
    Value<DateTime?>? actualizadoEn,
    Value<int>? rowid,
  }) {
    return FormulariosCacheCompanion(
      id: id ?? this.id,
      json: json ?? this.json,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FormulariosCacheCompanion(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentosKitCacheTable extends DocumentosKitCache
    with TableInfo<$DocumentosKitCacheTable, DocumentoKitCacheRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentosKitCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tramiteIdMeta = const VerificationMeta(
    'tramiteId',
  );
  @override
  late final GeneratedColumn<String> tramiteId = GeneratedColumn<String>(
    'tramite_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadoEn =
      GeneratedColumn<DateTime>(
        'actualizado_en',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [tramiteId, json, actualizadoEn];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'documentos_kit_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentoKitCacheRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tramite_id')) {
      context.handle(
        _tramiteIdMeta,
        tramiteId.isAcceptableOrUnknown(data['tramite_id']!, _tramiteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tramiteIdMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tramiteId};
  @override
  DocumentoKitCacheRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentoKitCacheRow(
      tramiteId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}tramite_id'],
          )!,
      json:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}json'],
          )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizado_en'],
      ),
    );
  }

  @override
  $DocumentosKitCacheTable createAlias(String alias) {
    return $DocumentosKitCacheTable(attachedDatabase, alias);
  }
}

class DocumentoKitCacheRow extends DataClass
    implements Insertable<DocumentoKitCacheRow> {
  final String tramiteId;
  final String json;
  final DateTime? actualizadoEn;
  const DocumentoKitCacheRow({
    required this.tramiteId,
    required this.json,
    this.actualizadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tramite_id'] = Variable<String>(tramiteId);
    map['json'] = Variable<String>(json);
    if (!nullToAbsent || actualizadoEn != null) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn);
    }
    return map;
  }

  DocumentosKitCacheCompanion toCompanion(bool nullToAbsent) {
    return DocumentosKitCacheCompanion(
      tramiteId: Value(tramiteId),
      json: Value(json),
      actualizadoEn:
          actualizadoEn == null && nullToAbsent
              ? const Value.absent()
              : Value(actualizadoEn),
    );
  }

  factory DocumentoKitCacheRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentoKitCacheRow(
      tramiteId: serializer.fromJson<String>(json['tramiteId']),
      json: serializer.fromJson<String>(json['json']),
      actualizadoEn: serializer.fromJson<DateTime?>(json['actualizadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tramiteId': serializer.toJson<String>(tramiteId),
      'json': serializer.toJson<String>(json),
      'actualizadoEn': serializer.toJson<DateTime?>(actualizadoEn),
    };
  }

  DocumentoKitCacheRow copyWith({
    String? tramiteId,
    String? json,
    Value<DateTime?> actualizadoEn = const Value.absent(),
  }) => DocumentoKitCacheRow(
    tramiteId: tramiteId ?? this.tramiteId,
    json: json ?? this.json,
    actualizadoEn:
        actualizadoEn.present ? actualizadoEn.value : this.actualizadoEn,
  );
  DocumentoKitCacheRow copyWithCompanion(DocumentosKitCacheCompanion data) {
    return DocumentoKitCacheRow(
      tramiteId: data.tramiteId.present ? data.tramiteId.value : this.tramiteId,
      json: data.json.present ? data.json.value : this.json,
      actualizadoEn:
          data.actualizadoEn.present
              ? data.actualizadoEn.value
              : this.actualizadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentoKitCacheRow(')
          ..write('tramiteId: $tramiteId, ')
          ..write('json: $json, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tramiteId, json, actualizadoEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentoKitCacheRow &&
          other.tramiteId == this.tramiteId &&
          other.json == this.json &&
          other.actualizadoEn == this.actualizadoEn);
}

class DocumentosKitCacheCompanion
    extends UpdateCompanion<DocumentoKitCacheRow> {
  final Value<String> tramiteId;
  final Value<String> json;
  final Value<DateTime?> actualizadoEn;
  final Value<int> rowid;
  const DocumentosKitCacheCompanion({
    this.tramiteId = const Value.absent(),
    this.json = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentosKitCacheCompanion.insert({
    required String tramiteId,
    required String json,
    this.actualizadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : tramiteId = Value(tramiteId),
       json = Value(json);
  static Insertable<DocumentoKitCacheRow> custom({
    Expression<String>? tramiteId,
    Expression<String>? json,
    Expression<DateTime>? actualizadoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tramiteId != null) 'tramite_id': tramiteId,
      if (json != null) 'json': json,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentosKitCacheCompanion copyWith({
    Value<String>? tramiteId,
    Value<String>? json,
    Value<DateTime?>? actualizadoEn,
    Value<int>? rowid,
  }) {
    return DocumentosKitCacheCompanion(
      tramiteId: tramiteId ?? this.tramiteId,
      json: json ?? this.json,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tramiteId.present) {
      map['tramite_id'] = Variable<String>(tramiteId.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentosKitCacheCompanion(')
          ..write('tramiteId: $tramiteId, ')
          ..write('json: $json, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxOperacionesTable extends OutboxOperaciones
    with TableInfo<$OutboxOperacionesTable, OutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxOperacionesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pendiente'),
  );
  static const VerificationMeta _intentosMeta = const VerificationMeta(
    'intentos',
  );
  @override
  late final GeneratedColumn<int> intentos = GeneratedColumn<int>(
    'intentos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ultimoErrorMeta = const VerificationMeta(
    'ultimoError',
  );
  @override
  late final GeneratedColumn<String> ultimoError = GeneratedColumn<String>(
    'ultimo_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    tipo,
    payloadJson,
    estado,
    intentos,
    ultimoError,
    creadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_operaciones';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    }
    if (data.containsKey('intentos')) {
      context.handle(
        _intentosMeta,
        intentos.isAcceptableOrUnknown(data['intentos']!, _intentosMeta),
      );
    }
    if (data.containsKey('ultimo_error')) {
      context.handle(
        _ultimoErrorMeta,
        ultimoError.isAcceptableOrUnknown(
          data['ultimo_error']!,
          _ultimoErrorMeta,
        ),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      clientId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}client_id'],
          )!,
      tipo:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}tipo'],
          )!,
      payloadJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}payload_json'],
          )!,
      estado:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}estado'],
          )!,
      intentos:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}intentos'],
          )!,
      ultimoError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ultimo_error'],
      ),
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      ),
    );
  }

  @override
  $OutboxOperacionesTable createAlias(String alias) {
    return $OutboxOperacionesTable(attachedDatabase, alias);
  }
}

class OutboxRow extends DataClass implements Insertable<OutboxRow> {
  final int id;

  /// UUID idempotente que se manda al backend para deduplicar reintentos.
  final String clientId;

  /// Tipo de operación, ej: "crear_solicitud".
  final String tipo;

  /// Datos de la operación (tramiteId, respuestas, archivos locales…).
  final String payloadJson;

  /// "pendiente" | "error".
  final String estado;
  final int intentos;
  final String? ultimoError;
  final DateTime? creadoEn;
  const OutboxRow({
    required this.id,
    required this.clientId,
    required this.tipo,
    required this.payloadJson,
    required this.estado,
    required this.intentos,
    this.ultimoError,
    this.creadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['client_id'] = Variable<String>(clientId);
    map['tipo'] = Variable<String>(tipo);
    map['payload_json'] = Variable<String>(payloadJson);
    map['estado'] = Variable<String>(estado);
    map['intentos'] = Variable<int>(intentos);
    if (!nullToAbsent || ultimoError != null) {
      map['ultimo_error'] = Variable<String>(ultimoError);
    }
    if (!nullToAbsent || creadoEn != null) {
      map['creado_en'] = Variable<DateTime>(creadoEn);
    }
    return map;
  }

  OutboxOperacionesCompanion toCompanion(bool nullToAbsent) {
    return OutboxOperacionesCompanion(
      id: Value(id),
      clientId: Value(clientId),
      tipo: Value(tipo),
      payloadJson: Value(payloadJson),
      estado: Value(estado),
      intentos: Value(intentos),
      ultimoError:
          ultimoError == null && nullToAbsent
              ? const Value.absent()
              : Value(ultimoError),
      creadoEn:
          creadoEn == null && nullToAbsent
              ? const Value.absent()
              : Value(creadoEn),
    );
  }

  factory OutboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxRow(
      id: serializer.fromJson<int>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      tipo: serializer.fromJson<String>(json['tipo']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      estado: serializer.fromJson<String>(json['estado']),
      intentos: serializer.fromJson<int>(json['intentos']),
      ultimoError: serializer.fromJson<String?>(json['ultimoError']),
      creadoEn: serializer.fromJson<DateTime?>(json['creadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clientId': serializer.toJson<String>(clientId),
      'tipo': serializer.toJson<String>(tipo),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'estado': serializer.toJson<String>(estado),
      'intentos': serializer.toJson<int>(intentos),
      'ultimoError': serializer.toJson<String?>(ultimoError),
      'creadoEn': serializer.toJson<DateTime?>(creadoEn),
    };
  }

  OutboxRow copyWith({
    int? id,
    String? clientId,
    String? tipo,
    String? payloadJson,
    String? estado,
    int? intentos,
    Value<String?> ultimoError = const Value.absent(),
    Value<DateTime?> creadoEn = const Value.absent(),
  }) => OutboxRow(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    tipo: tipo ?? this.tipo,
    payloadJson: payloadJson ?? this.payloadJson,
    estado: estado ?? this.estado,
    intentos: intentos ?? this.intentos,
    ultimoError: ultimoError.present ? ultimoError.value : this.ultimoError,
    creadoEn: creadoEn.present ? creadoEn.value : this.creadoEn,
  );
  OutboxRow copyWithCompanion(OutboxOperacionesCompanion data) {
    return OutboxRow(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      estado: data.estado.present ? data.estado.value : this.estado,
      intentos: data.intentos.present ? data.intentos.value : this.intentos,
      ultimoError:
          data.ultimoError.present ? data.ultimoError.value : this.ultimoError,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRow(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('tipo: $tipo, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('estado: $estado, ')
          ..write('intentos: $intentos, ')
          ..write('ultimoError: $ultimoError, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientId,
    tipo,
    payloadJson,
    estado,
    intentos,
    ultimoError,
    creadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxRow &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.tipo == this.tipo &&
          other.payloadJson == this.payloadJson &&
          other.estado == this.estado &&
          other.intentos == this.intentos &&
          other.ultimoError == this.ultimoError &&
          other.creadoEn == this.creadoEn);
}

class OutboxOperacionesCompanion extends UpdateCompanion<OutboxRow> {
  final Value<int> id;
  final Value<String> clientId;
  final Value<String> tipo;
  final Value<String> payloadJson;
  final Value<String> estado;
  final Value<int> intentos;
  final Value<String?> ultimoError;
  final Value<DateTime?> creadoEn;
  const OutboxOperacionesCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.estado = const Value.absent(),
    this.intentos = const Value.absent(),
    this.ultimoError = const Value.absent(),
    this.creadoEn = const Value.absent(),
  });
  OutboxOperacionesCompanion.insert({
    this.id = const Value.absent(),
    required String clientId,
    required String tipo,
    required String payloadJson,
    this.estado = const Value.absent(),
    this.intentos = const Value.absent(),
    this.ultimoError = const Value.absent(),
    this.creadoEn = const Value.absent(),
  }) : clientId = Value(clientId),
       tipo = Value(tipo),
       payloadJson = Value(payloadJson);
  static Insertable<OutboxRow> custom({
    Expression<int>? id,
    Expression<String>? clientId,
    Expression<String>? tipo,
    Expression<String>? payloadJson,
    Expression<String>? estado,
    Expression<int>? intentos,
    Expression<String>? ultimoError,
    Expression<DateTime>? creadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (tipo != null) 'tipo': tipo,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (estado != null) 'estado': estado,
      if (intentos != null) 'intentos': intentos,
      if (ultimoError != null) 'ultimo_error': ultimoError,
      if (creadoEn != null) 'creado_en': creadoEn,
    });
  }

  OutboxOperacionesCompanion copyWith({
    Value<int>? id,
    Value<String>? clientId,
    Value<String>? tipo,
    Value<String>? payloadJson,
    Value<String>? estado,
    Value<int>? intentos,
    Value<String?>? ultimoError,
    Value<DateTime?>? creadoEn,
  }) {
    return OutboxOperacionesCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      tipo: tipo ?? this.tipo,
      payloadJson: payloadJson ?? this.payloadJson,
      estado: estado ?? this.estado,
      intentos: intentos ?? this.intentos,
      ultimoError: ultimoError ?? this.ultimoError,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (intentos.present) {
      map['intentos'] = Variable<int>(intentos.value);
    }
    if (ultimoError.present) {
      map['ultimo_error'] = Variable<String>(ultimoError.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxOperacionesCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('tipo: $tipo, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('estado: $estado, ')
          ..write('intentos: $intentos, ')
          ..write('ultimoError: $ultimoError, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }
}

class $ArchivosTable extends Archivos
    with TableInfo<$ArchivosTable, ArchivoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArchivosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _solicitudIdMeta = const VerificationMeta(
    'solicitudId',
  );
  @override
  late final GeneratedColumn<String> solicitudId = GeneratedColumn<String>(
    'solicitud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _formatoMeta = const VerificationMeta(
    'formato',
  );
  @override
  late final GeneratedColumn<String> formato = GeneratedColumn<String>(
    'formato',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tamanoBytesMeta = const VerificationMeta(
    'tamanoBytes',
  );
  @override
  late final GeneratedColumn<int> tamanoBytes = GeneratedColumn<int>(
    'tamano_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _campoFormularioOrigenMeta =
      const VerificationMeta('campoFormularioOrigen');
  @override
  late final GeneratedColumn<String> campoFormularioOrigen =
      GeneratedColumn<String>(
        'campo_formulario_origen',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _pathLocalMeta = const VerificationMeta(
    'pathLocal',
  );
  @override
  late final GeneratedColumn<String> pathLocal = GeneratedColumn<String>(
    'path_local',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadoEn =
      GeneratedColumn<DateTime>(
        'actualizado_en',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    solicitudId,
    nombre,
    formato,
    contentType,
    tamanoBytes,
    campoFormularioOrigen,
    pathLocal,
    actualizadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'archivos';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArchivoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('solicitud_id')) {
      context.handle(
        _solicitudIdMeta,
        solicitudId.isAcceptableOrUnknown(
          data['solicitud_id']!,
          _solicitudIdMeta,
        ),
      );
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    }
    if (data.containsKey('formato')) {
      context.handle(
        _formatoMeta,
        formato.isAcceptableOrUnknown(data['formato']!, _formatoMeta),
      );
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    }
    if (data.containsKey('tamano_bytes')) {
      context.handle(
        _tamanoBytesMeta,
        tamanoBytes.isAcceptableOrUnknown(
          data['tamano_bytes']!,
          _tamanoBytesMeta,
        ),
      );
    }
    if (data.containsKey('campo_formulario_origen')) {
      context.handle(
        _campoFormularioOrigenMeta,
        campoFormularioOrigen.isAcceptableOrUnknown(
          data['campo_formulario_origen']!,
          _campoFormularioOrigenMeta,
        ),
      );
    }
    if (data.containsKey('path_local')) {
      context.handle(
        _pathLocalMeta,
        pathLocal.isAcceptableOrUnknown(data['path_local']!, _pathLocalMeta),
      );
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ArchivoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArchivoRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      solicitudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}solicitud_id'],
      ),
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      ),
      formato: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}formato'],
      ),
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      ),
      tamanoBytes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}tamano_bytes'],
          )!,
      campoFormularioOrigen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}campo_formulario_origen'],
      ),
      pathLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path_local'],
      ),
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizado_en'],
      ),
    );
  }

  @override
  $ArchivosTable createAlias(String alias) {
    return $ArchivosTable(attachedDatabase, alias);
  }
}

class ArchivoRow extends DataClass implements Insertable<ArchivoRow> {
  final String id;
  final String? solicitudId;
  final String? nombre;
  final String? formato;
  final String? contentType;
  final int tamanoBytes;
  final String? campoFormularioOrigen;

  /// Ruta del archivo descargado en el dispositivo (null = no descargado).
  final String? pathLocal;
  final DateTime? actualizadoEn;
  const ArchivoRow({
    required this.id,
    this.solicitudId,
    this.nombre,
    this.formato,
    this.contentType,
    required this.tamanoBytes,
    this.campoFormularioOrigen,
    this.pathLocal,
    this.actualizadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || solicitudId != null) {
      map['solicitud_id'] = Variable<String>(solicitudId);
    }
    if (!nullToAbsent || nombre != null) {
      map['nombre'] = Variable<String>(nombre);
    }
    if (!nullToAbsent || formato != null) {
      map['formato'] = Variable<String>(formato);
    }
    if (!nullToAbsent || contentType != null) {
      map['content_type'] = Variable<String>(contentType);
    }
    map['tamano_bytes'] = Variable<int>(tamanoBytes);
    if (!nullToAbsent || campoFormularioOrigen != null) {
      map['campo_formulario_origen'] = Variable<String>(campoFormularioOrigen);
    }
    if (!nullToAbsent || pathLocal != null) {
      map['path_local'] = Variable<String>(pathLocal);
    }
    if (!nullToAbsent || actualizadoEn != null) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn);
    }
    return map;
  }

  ArchivosCompanion toCompanion(bool nullToAbsent) {
    return ArchivosCompanion(
      id: Value(id),
      solicitudId:
          solicitudId == null && nullToAbsent
              ? const Value.absent()
              : Value(solicitudId),
      nombre:
          nombre == null && nullToAbsent ? const Value.absent() : Value(nombre),
      formato:
          formato == null && nullToAbsent
              ? const Value.absent()
              : Value(formato),
      contentType:
          contentType == null && nullToAbsent
              ? const Value.absent()
              : Value(contentType),
      tamanoBytes: Value(tamanoBytes),
      campoFormularioOrigen:
          campoFormularioOrigen == null && nullToAbsent
              ? const Value.absent()
              : Value(campoFormularioOrigen),
      pathLocal:
          pathLocal == null && nullToAbsent
              ? const Value.absent()
              : Value(pathLocal),
      actualizadoEn:
          actualizadoEn == null && nullToAbsent
              ? const Value.absent()
              : Value(actualizadoEn),
    );
  }

  factory ArchivoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArchivoRow(
      id: serializer.fromJson<String>(json['id']),
      solicitudId: serializer.fromJson<String?>(json['solicitudId']),
      nombre: serializer.fromJson<String?>(json['nombre']),
      formato: serializer.fromJson<String?>(json['formato']),
      contentType: serializer.fromJson<String?>(json['contentType']),
      tamanoBytes: serializer.fromJson<int>(json['tamanoBytes']),
      campoFormularioOrigen: serializer.fromJson<String?>(
        json['campoFormularioOrigen'],
      ),
      pathLocal: serializer.fromJson<String?>(json['pathLocal']),
      actualizadoEn: serializer.fromJson<DateTime?>(json['actualizadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'solicitudId': serializer.toJson<String?>(solicitudId),
      'nombre': serializer.toJson<String?>(nombre),
      'formato': serializer.toJson<String?>(formato),
      'contentType': serializer.toJson<String?>(contentType),
      'tamanoBytes': serializer.toJson<int>(tamanoBytes),
      'campoFormularioOrigen': serializer.toJson<String?>(
        campoFormularioOrigen,
      ),
      'pathLocal': serializer.toJson<String?>(pathLocal),
      'actualizadoEn': serializer.toJson<DateTime?>(actualizadoEn),
    };
  }

  ArchivoRow copyWith({
    String? id,
    Value<String?> solicitudId = const Value.absent(),
    Value<String?> nombre = const Value.absent(),
    Value<String?> formato = const Value.absent(),
    Value<String?> contentType = const Value.absent(),
    int? tamanoBytes,
    Value<String?> campoFormularioOrigen = const Value.absent(),
    Value<String?> pathLocal = const Value.absent(),
    Value<DateTime?> actualizadoEn = const Value.absent(),
  }) => ArchivoRow(
    id: id ?? this.id,
    solicitudId: solicitudId.present ? solicitudId.value : this.solicitudId,
    nombre: nombre.present ? nombre.value : this.nombre,
    formato: formato.present ? formato.value : this.formato,
    contentType: contentType.present ? contentType.value : this.contentType,
    tamanoBytes: tamanoBytes ?? this.tamanoBytes,
    campoFormularioOrigen:
        campoFormularioOrigen.present
            ? campoFormularioOrigen.value
            : this.campoFormularioOrigen,
    pathLocal: pathLocal.present ? pathLocal.value : this.pathLocal,
    actualizadoEn:
        actualizadoEn.present ? actualizadoEn.value : this.actualizadoEn,
  );
  ArchivoRow copyWithCompanion(ArchivosCompanion data) {
    return ArchivoRow(
      id: data.id.present ? data.id.value : this.id,
      solicitudId:
          data.solicitudId.present ? data.solicitudId.value : this.solicitudId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      formato: data.formato.present ? data.formato.value : this.formato,
      contentType:
          data.contentType.present ? data.contentType.value : this.contentType,
      tamanoBytes:
          data.tamanoBytes.present ? data.tamanoBytes.value : this.tamanoBytes,
      campoFormularioOrigen:
          data.campoFormularioOrigen.present
              ? data.campoFormularioOrigen.value
              : this.campoFormularioOrigen,
      pathLocal: data.pathLocal.present ? data.pathLocal.value : this.pathLocal,
      actualizadoEn:
          data.actualizadoEn.present
              ? data.actualizadoEn.value
              : this.actualizadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArchivoRow(')
          ..write('id: $id, ')
          ..write('solicitudId: $solicitudId, ')
          ..write('nombre: $nombre, ')
          ..write('formato: $formato, ')
          ..write('contentType: $contentType, ')
          ..write('tamanoBytes: $tamanoBytes, ')
          ..write('campoFormularioOrigen: $campoFormularioOrigen, ')
          ..write('pathLocal: $pathLocal, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    solicitudId,
    nombre,
    formato,
    contentType,
    tamanoBytes,
    campoFormularioOrigen,
    pathLocal,
    actualizadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArchivoRow &&
          other.id == this.id &&
          other.solicitudId == this.solicitudId &&
          other.nombre == this.nombre &&
          other.formato == this.formato &&
          other.contentType == this.contentType &&
          other.tamanoBytes == this.tamanoBytes &&
          other.campoFormularioOrigen == this.campoFormularioOrigen &&
          other.pathLocal == this.pathLocal &&
          other.actualizadoEn == this.actualizadoEn);
}

class ArchivosCompanion extends UpdateCompanion<ArchivoRow> {
  final Value<String> id;
  final Value<String?> solicitudId;
  final Value<String?> nombre;
  final Value<String?> formato;
  final Value<String?> contentType;
  final Value<int> tamanoBytes;
  final Value<String?> campoFormularioOrigen;
  final Value<String?> pathLocal;
  final Value<DateTime?> actualizadoEn;
  final Value<int> rowid;
  const ArchivosCompanion({
    this.id = const Value.absent(),
    this.solicitudId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.formato = const Value.absent(),
    this.contentType = const Value.absent(),
    this.tamanoBytes = const Value.absent(),
    this.campoFormularioOrigen = const Value.absent(),
    this.pathLocal = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArchivosCompanion.insert({
    required String id,
    this.solicitudId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.formato = const Value.absent(),
    this.contentType = const Value.absent(),
    this.tamanoBytes = const Value.absent(),
    this.campoFormularioOrigen = const Value.absent(),
    this.pathLocal = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<ArchivoRow> custom({
    Expression<String>? id,
    Expression<String>? solicitudId,
    Expression<String>? nombre,
    Expression<String>? formato,
    Expression<String>? contentType,
    Expression<int>? tamanoBytes,
    Expression<String>? campoFormularioOrigen,
    Expression<String>? pathLocal,
    Expression<DateTime>? actualizadoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (solicitudId != null) 'solicitud_id': solicitudId,
      if (nombre != null) 'nombre': nombre,
      if (formato != null) 'formato': formato,
      if (contentType != null) 'content_type': contentType,
      if (tamanoBytes != null) 'tamano_bytes': tamanoBytes,
      if (campoFormularioOrigen != null)
        'campo_formulario_origen': campoFormularioOrigen,
      if (pathLocal != null) 'path_local': pathLocal,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArchivosCompanion copyWith({
    Value<String>? id,
    Value<String?>? solicitudId,
    Value<String?>? nombre,
    Value<String?>? formato,
    Value<String?>? contentType,
    Value<int>? tamanoBytes,
    Value<String?>? campoFormularioOrigen,
    Value<String?>? pathLocal,
    Value<DateTime?>? actualizadoEn,
    Value<int>? rowid,
  }) {
    return ArchivosCompanion(
      id: id ?? this.id,
      solicitudId: solicitudId ?? this.solicitudId,
      nombre: nombre ?? this.nombre,
      formato: formato ?? this.formato,
      contentType: contentType ?? this.contentType,
      tamanoBytes: tamanoBytes ?? this.tamanoBytes,
      campoFormularioOrigen:
          campoFormularioOrigen ?? this.campoFormularioOrigen,
      pathLocal: pathLocal ?? this.pathLocal,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (solicitudId.present) {
      map['solicitud_id'] = Variable<String>(solicitudId.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (formato.present) {
      map['formato'] = Variable<String>(formato.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (tamanoBytes.present) {
      map['tamano_bytes'] = Variable<int>(tamanoBytes.value);
    }
    if (campoFormularioOrigen.present) {
      map['campo_formulario_origen'] = Variable<String>(
        campoFormularioOrigen.value,
      );
    }
    if (pathLocal.present) {
      map['path_local'] = Variable<String>(pathLocal.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArchivosCompanion(')
          ..write('id: $id, ')
          ..write('solicitudId: $solicitudId, ')
          ..write('nombre: $nombre, ')
          ..write('formato: $formato, ')
          ..write('contentType: $contentType, ')
          ..write('tamanoBytes: $tamanoBytes, ')
          ..write('campoFormularioOrigen: $campoFormularioOrigen, ')
          ..write('pathLocal: $pathLocal, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SolicitudesTable solicitudes = $SolicitudesTable(this);
  late final $TramitesTable tramites = $TramitesTable(this);
  late final $FormulariosCacheTable formulariosCache = $FormulariosCacheTable(
    this,
  );
  late final $DocumentosKitCacheTable documentosKitCache =
      $DocumentosKitCacheTable(this);
  late final $OutboxOperacionesTable outboxOperaciones =
      $OutboxOperacionesTable(this);
  late final $ArchivosTable archivos = $ArchivosTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    solicitudes,
    tramites,
    formulariosCache,
    documentosKitCache,
    outboxOperaciones,
    archivos,
  ];
}

typedef $$SolicitudesTableCreateCompanionBuilder =
    SolicitudesCompanion Function({
      required String id,
      Value<String?> tramiteId,
      Value<String?> tramiteNombre,
      Value<String?> estado,
      Value<DateTime?> fechaCreacion,
      Value<DateTime?> fechaFinalizacion,
      Value<String?> detalleJson,
      Value<bool> pendienteSync,
      Value<String?> clientId,
      Value<String?> syncError,
      Value<DateTime?> actualizadoEn,
      Value<int> rowid,
    });
typedef $$SolicitudesTableUpdateCompanionBuilder =
    SolicitudesCompanion Function({
      Value<String> id,
      Value<String?> tramiteId,
      Value<String?> tramiteNombre,
      Value<String?> estado,
      Value<DateTime?> fechaCreacion,
      Value<DateTime?> fechaFinalizacion,
      Value<String?> detalleJson,
      Value<bool> pendienteSync,
      Value<String?> clientId,
      Value<String?> syncError,
      Value<DateTime?> actualizadoEn,
      Value<int> rowid,
    });

class $$SolicitudesTableFilterComposer
    extends Composer<_$AppDatabase, $SolicitudesTable> {
  $$SolicitudesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tramiteId => $composableBuilder(
    column: $table.tramiteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tramiteNombre => $composableBuilder(
    column: $table.tramiteNombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaCreacion => $composableBuilder(
    column: $table.fechaCreacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaFinalizacion => $composableBuilder(
    column: $table.fechaFinalizacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detalleJson => $composableBuilder(
    column: $table.detalleJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendienteSync => $composableBuilder(
    column: $table.pendienteSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SolicitudesTableOrderingComposer
    extends Composer<_$AppDatabase, $SolicitudesTable> {
  $$SolicitudesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tramiteId => $composableBuilder(
    column: $table.tramiteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tramiteNombre => $composableBuilder(
    column: $table.tramiteNombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaCreacion => $composableBuilder(
    column: $table.fechaCreacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaFinalizacion => $composableBuilder(
    column: $table.fechaFinalizacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detalleJson => $composableBuilder(
    column: $table.detalleJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendienteSync => $composableBuilder(
    column: $table.pendienteSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SolicitudesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SolicitudesTable> {
  $$SolicitudesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tramiteId =>
      $composableBuilder(column: $table.tramiteId, builder: (column) => column);

  GeneratedColumn<String> get tramiteNombre => $composableBuilder(
    column: $table.tramiteNombre,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaCreacion => $composableBuilder(
    column: $table.fechaCreacion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fechaFinalizacion => $composableBuilder(
    column: $table.fechaFinalizacion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detalleJson => $composableBuilder(
    column: $table.detalleJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pendienteSync => $composableBuilder(
    column: $table.pendienteSync,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);

  GeneratedColumn<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );
}

class $$SolicitudesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SolicitudesTable,
          SolicitudRow,
          $$SolicitudesTableFilterComposer,
          $$SolicitudesTableOrderingComposer,
          $$SolicitudesTableAnnotationComposer,
          $$SolicitudesTableCreateCompanionBuilder,
          $$SolicitudesTableUpdateCompanionBuilder,
          (
            SolicitudRow,
            BaseReferences<_$AppDatabase, $SolicitudesTable, SolicitudRow>,
          ),
          SolicitudRow,
          PrefetchHooks Function()
        > {
  $$SolicitudesTableTableManager(_$AppDatabase db, $SolicitudesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SolicitudesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SolicitudesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$SolicitudesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> tramiteId = const Value.absent(),
                Value<String?> tramiteNombre = const Value.absent(),
                Value<String?> estado = const Value.absent(),
                Value<DateTime?> fechaCreacion = const Value.absent(),
                Value<DateTime?> fechaFinalizacion = const Value.absent(),
                Value<String?> detalleJson = const Value.absent(),
                Value<bool> pendienteSync = const Value.absent(),
                Value<String?> clientId = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<DateTime?> actualizadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SolicitudesCompanion(
                id: id,
                tramiteId: tramiteId,
                tramiteNombre: tramiteNombre,
                estado: estado,
                fechaCreacion: fechaCreacion,
                fechaFinalizacion: fechaFinalizacion,
                detalleJson: detalleJson,
                pendienteSync: pendienteSync,
                clientId: clientId,
                syncError: syncError,
                actualizadoEn: actualizadoEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> tramiteId = const Value.absent(),
                Value<String?> tramiteNombre = const Value.absent(),
                Value<String?> estado = const Value.absent(),
                Value<DateTime?> fechaCreacion = const Value.absent(),
                Value<DateTime?> fechaFinalizacion = const Value.absent(),
                Value<String?> detalleJson = const Value.absent(),
                Value<bool> pendienteSync = const Value.absent(),
                Value<String?> clientId = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<DateTime?> actualizadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SolicitudesCompanion.insert(
                id: id,
                tramiteId: tramiteId,
                tramiteNombre: tramiteNombre,
                estado: estado,
                fechaCreacion: fechaCreacion,
                fechaFinalizacion: fechaFinalizacion,
                detalleJson: detalleJson,
                pendienteSync: pendienteSync,
                clientId: clientId,
                syncError: syncError,
                actualizadoEn: actualizadoEn,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SolicitudesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SolicitudesTable,
      SolicitudRow,
      $$SolicitudesTableFilterComposer,
      $$SolicitudesTableOrderingComposer,
      $$SolicitudesTableAnnotationComposer,
      $$SolicitudesTableCreateCompanionBuilder,
      $$SolicitudesTableUpdateCompanionBuilder,
      (
        SolicitudRow,
        BaseReferences<_$AppDatabase, $SolicitudesTable, SolicitudRow>,
      ),
      SolicitudRow,
      PrefetchHooks Function()
    >;
typedef $$TramitesTableCreateCompanionBuilder =
    TramitesCompanion Function({
      required String id,
      Value<String?> nombre,
      Value<String?> descripcion,
      Value<String?> formularioSolicitanteId,
      Value<bool> activo,
      required String json,
      Value<DateTime?> actualizadoEn,
      Value<int> rowid,
    });
typedef $$TramitesTableUpdateCompanionBuilder =
    TramitesCompanion Function({
      Value<String> id,
      Value<String?> nombre,
      Value<String?> descripcion,
      Value<String?> formularioSolicitanteId,
      Value<bool> activo,
      Value<String> json,
      Value<DateTime?> actualizadoEn,
      Value<int> rowid,
    });

class $$TramitesTableFilterComposer
    extends Composer<_$AppDatabase, $TramitesTable> {
  $$TramitesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formularioSolicitanteId => $composableBuilder(
    column: $table.formularioSolicitanteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TramitesTableOrderingComposer
    extends Composer<_$AppDatabase, $TramitesTable> {
  $$TramitesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formularioSolicitanteId => $composableBuilder(
    column: $table.formularioSolicitanteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TramitesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TramitesTable> {
  $$TramitesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get formularioSolicitanteId => $composableBuilder(
    column: $table.formularioSolicitanteId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );
}

class $$TramitesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TramitesTable,
          TramiteRow,
          $$TramitesTableFilterComposer,
          $$TramitesTableOrderingComposer,
          $$TramitesTableAnnotationComposer,
          $$TramitesTableCreateCompanionBuilder,
          $$TramitesTableUpdateCompanionBuilder,
          (
            TramiteRow,
            BaseReferences<_$AppDatabase, $TramitesTable, TramiteRow>,
          ),
          TramiteRow,
          PrefetchHooks Function()
        > {
  $$TramitesTableTableManager(_$AppDatabase db, $TramitesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$TramitesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$TramitesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$TramitesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> nombre = const Value.absent(),
                Value<String?> descripcion = const Value.absent(),
                Value<String?> formularioSolicitanteId = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<DateTime?> actualizadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TramitesCompanion(
                id: id,
                nombre: nombre,
                descripcion: descripcion,
                formularioSolicitanteId: formularioSolicitanteId,
                activo: activo,
                json: json,
                actualizadoEn: actualizadoEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> nombre = const Value.absent(),
                Value<String?> descripcion = const Value.absent(),
                Value<String?> formularioSolicitanteId = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                required String json,
                Value<DateTime?> actualizadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TramitesCompanion.insert(
                id: id,
                nombre: nombre,
                descripcion: descripcion,
                formularioSolicitanteId: formularioSolicitanteId,
                activo: activo,
                json: json,
                actualizadoEn: actualizadoEn,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TramitesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TramitesTable,
      TramiteRow,
      $$TramitesTableFilterComposer,
      $$TramitesTableOrderingComposer,
      $$TramitesTableAnnotationComposer,
      $$TramitesTableCreateCompanionBuilder,
      $$TramitesTableUpdateCompanionBuilder,
      (TramiteRow, BaseReferences<_$AppDatabase, $TramitesTable, TramiteRow>),
      TramiteRow,
      PrefetchHooks Function()
    >;
typedef $$FormulariosCacheTableCreateCompanionBuilder =
    FormulariosCacheCompanion Function({
      required String id,
      required String json,
      Value<DateTime?> actualizadoEn,
      Value<int> rowid,
    });
typedef $$FormulariosCacheTableUpdateCompanionBuilder =
    FormulariosCacheCompanion Function({
      Value<String> id,
      Value<String> json,
      Value<DateTime?> actualizadoEn,
      Value<int> rowid,
    });

class $$FormulariosCacheTableFilterComposer
    extends Composer<_$AppDatabase, $FormulariosCacheTable> {
  $$FormulariosCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FormulariosCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $FormulariosCacheTable> {
  $$FormulariosCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FormulariosCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $FormulariosCacheTable> {
  $$FormulariosCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );
}

class $$FormulariosCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FormulariosCacheTable,
          FormularioCacheRow,
          $$FormulariosCacheTableFilterComposer,
          $$FormulariosCacheTableOrderingComposer,
          $$FormulariosCacheTableAnnotationComposer,
          $$FormulariosCacheTableCreateCompanionBuilder,
          $$FormulariosCacheTableUpdateCompanionBuilder,
          (
            FormularioCacheRow,
            BaseReferences<
              _$AppDatabase,
              $FormulariosCacheTable,
              FormularioCacheRow
            >,
          ),
          FormularioCacheRow,
          PrefetchHooks Function()
        > {
  $$FormulariosCacheTableTableManager(
    _$AppDatabase db,
    $FormulariosCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$FormulariosCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$FormulariosCacheTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$FormulariosCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<DateTime?> actualizadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FormulariosCacheCompanion(
                id: id,
                json: json,
                actualizadoEn: actualizadoEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String json,
                Value<DateTime?> actualizadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FormulariosCacheCompanion.insert(
                id: id,
                json: json,
                actualizadoEn: actualizadoEn,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FormulariosCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FormulariosCacheTable,
      FormularioCacheRow,
      $$FormulariosCacheTableFilterComposer,
      $$FormulariosCacheTableOrderingComposer,
      $$FormulariosCacheTableAnnotationComposer,
      $$FormulariosCacheTableCreateCompanionBuilder,
      $$FormulariosCacheTableUpdateCompanionBuilder,
      (
        FormularioCacheRow,
        BaseReferences<
          _$AppDatabase,
          $FormulariosCacheTable,
          FormularioCacheRow
        >,
      ),
      FormularioCacheRow,
      PrefetchHooks Function()
    >;
typedef $$DocumentosKitCacheTableCreateCompanionBuilder =
    DocumentosKitCacheCompanion Function({
      required String tramiteId,
      required String json,
      Value<DateTime?> actualizadoEn,
      Value<int> rowid,
    });
typedef $$DocumentosKitCacheTableUpdateCompanionBuilder =
    DocumentosKitCacheCompanion Function({
      Value<String> tramiteId,
      Value<String> json,
      Value<DateTime?> actualizadoEn,
      Value<int> rowid,
    });

class $$DocumentosKitCacheTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentosKitCacheTable> {
  $$DocumentosKitCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tramiteId => $composableBuilder(
    column: $table.tramiteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DocumentosKitCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentosKitCacheTable> {
  $$DocumentosKitCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tramiteId => $composableBuilder(
    column: $table.tramiteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DocumentosKitCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentosKitCacheTable> {
  $$DocumentosKitCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tramiteId =>
      $composableBuilder(column: $table.tramiteId, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );
}

class $$DocumentosKitCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocumentosKitCacheTable,
          DocumentoKitCacheRow,
          $$DocumentosKitCacheTableFilterComposer,
          $$DocumentosKitCacheTableOrderingComposer,
          $$DocumentosKitCacheTableAnnotationComposer,
          $$DocumentosKitCacheTableCreateCompanionBuilder,
          $$DocumentosKitCacheTableUpdateCompanionBuilder,
          (
            DocumentoKitCacheRow,
            BaseReferences<
              _$AppDatabase,
              $DocumentosKitCacheTable,
              DocumentoKitCacheRow
            >,
          ),
          DocumentoKitCacheRow,
          PrefetchHooks Function()
        > {
  $$DocumentosKitCacheTableTableManager(
    _$AppDatabase db,
    $DocumentosKitCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$DocumentosKitCacheTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$DocumentosKitCacheTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$DocumentosKitCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> tramiteId = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<DateTime?> actualizadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentosKitCacheCompanion(
                tramiteId: tramiteId,
                json: json,
                actualizadoEn: actualizadoEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tramiteId,
                required String json,
                Value<DateTime?> actualizadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentosKitCacheCompanion.insert(
                tramiteId: tramiteId,
                json: json,
                actualizadoEn: actualizadoEn,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DocumentosKitCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocumentosKitCacheTable,
      DocumentoKitCacheRow,
      $$DocumentosKitCacheTableFilterComposer,
      $$DocumentosKitCacheTableOrderingComposer,
      $$DocumentosKitCacheTableAnnotationComposer,
      $$DocumentosKitCacheTableCreateCompanionBuilder,
      $$DocumentosKitCacheTableUpdateCompanionBuilder,
      (
        DocumentoKitCacheRow,
        BaseReferences<
          _$AppDatabase,
          $DocumentosKitCacheTable,
          DocumentoKitCacheRow
        >,
      ),
      DocumentoKitCacheRow,
      PrefetchHooks Function()
    >;
typedef $$OutboxOperacionesTableCreateCompanionBuilder =
    OutboxOperacionesCompanion Function({
      Value<int> id,
      required String clientId,
      required String tipo,
      required String payloadJson,
      Value<String> estado,
      Value<int> intentos,
      Value<String?> ultimoError,
      Value<DateTime?> creadoEn,
    });
typedef $$OutboxOperacionesTableUpdateCompanionBuilder =
    OutboxOperacionesCompanion Function({
      Value<int> id,
      Value<String> clientId,
      Value<String> tipo,
      Value<String> payloadJson,
      Value<String> estado,
      Value<int> intentos,
      Value<String?> ultimoError,
      Value<DateTime?> creadoEn,
    });

class $$OutboxOperacionesTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxOperacionesTable> {
  $$OutboxOperacionesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intentos => $composableBuilder(
    column: $table.intentos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ultimoError => $composableBuilder(
    column: $table.ultimoError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxOperacionesTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxOperacionesTable> {
  $$OutboxOperacionesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intentos => $composableBuilder(
    column: $table.intentos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ultimoError => $composableBuilder(
    column: $table.ultimoError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxOperacionesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxOperacionesTable> {
  $$OutboxOperacionesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<int> get intentos =>
      $composableBuilder(column: $table.intentos, builder: (column) => column);

  GeneratedColumn<String> get ultimoError => $composableBuilder(
    column: $table.ultimoError,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);
}

class $$OutboxOperacionesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxOperacionesTable,
          OutboxRow,
          $$OutboxOperacionesTableFilterComposer,
          $$OutboxOperacionesTableOrderingComposer,
          $$OutboxOperacionesTableAnnotationComposer,
          $$OutboxOperacionesTableCreateCompanionBuilder,
          $$OutboxOperacionesTableUpdateCompanionBuilder,
          (
            OutboxRow,
            BaseReferences<_$AppDatabase, $OutboxOperacionesTable, OutboxRow>,
          ),
          OutboxRow,
          PrefetchHooks Function()
        > {
  $$OutboxOperacionesTableTableManager(
    _$AppDatabase db,
    $OutboxOperacionesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$OutboxOperacionesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$OutboxOperacionesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$OutboxOperacionesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<int> intentos = const Value.absent(),
                Value<String?> ultimoError = const Value.absent(),
                Value<DateTime?> creadoEn = const Value.absent(),
              }) => OutboxOperacionesCompanion(
                id: id,
                clientId: clientId,
                tipo: tipo,
                payloadJson: payloadJson,
                estado: estado,
                intentos: intentos,
                ultimoError: ultimoError,
                creadoEn: creadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String clientId,
                required String tipo,
                required String payloadJson,
                Value<String> estado = const Value.absent(),
                Value<int> intentos = const Value.absent(),
                Value<String?> ultimoError = const Value.absent(),
                Value<DateTime?> creadoEn = const Value.absent(),
              }) => OutboxOperacionesCompanion.insert(
                id: id,
                clientId: clientId,
                tipo: tipo,
                payloadJson: payloadJson,
                estado: estado,
                intentos: intentos,
                ultimoError: ultimoError,
                creadoEn: creadoEn,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxOperacionesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxOperacionesTable,
      OutboxRow,
      $$OutboxOperacionesTableFilterComposer,
      $$OutboxOperacionesTableOrderingComposer,
      $$OutboxOperacionesTableAnnotationComposer,
      $$OutboxOperacionesTableCreateCompanionBuilder,
      $$OutboxOperacionesTableUpdateCompanionBuilder,
      (
        OutboxRow,
        BaseReferences<_$AppDatabase, $OutboxOperacionesTable, OutboxRow>,
      ),
      OutboxRow,
      PrefetchHooks Function()
    >;
typedef $$ArchivosTableCreateCompanionBuilder =
    ArchivosCompanion Function({
      required String id,
      Value<String?> solicitudId,
      Value<String?> nombre,
      Value<String?> formato,
      Value<String?> contentType,
      Value<int> tamanoBytes,
      Value<String?> campoFormularioOrigen,
      Value<String?> pathLocal,
      Value<DateTime?> actualizadoEn,
      Value<int> rowid,
    });
typedef $$ArchivosTableUpdateCompanionBuilder =
    ArchivosCompanion Function({
      Value<String> id,
      Value<String?> solicitudId,
      Value<String?> nombre,
      Value<String?> formato,
      Value<String?> contentType,
      Value<int> tamanoBytes,
      Value<String?> campoFormularioOrigen,
      Value<String?> pathLocal,
      Value<DateTime?> actualizadoEn,
      Value<int> rowid,
    });

class $$ArchivosTableFilterComposer
    extends Composer<_$AppDatabase, $ArchivosTable> {
  $$ArchivosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get solicitudId => $composableBuilder(
    column: $table.solicitudId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formato => $composableBuilder(
    column: $table.formato,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tamanoBytes => $composableBuilder(
    column: $table.tamanoBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get campoFormularioOrigen => $composableBuilder(
    column: $table.campoFormularioOrigen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pathLocal => $composableBuilder(
    column: $table.pathLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ArchivosTableOrderingComposer
    extends Composer<_$AppDatabase, $ArchivosTable> {
  $$ArchivosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get solicitudId => $composableBuilder(
    column: $table.solicitudId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formato => $composableBuilder(
    column: $table.formato,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tamanoBytes => $composableBuilder(
    column: $table.tamanoBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get campoFormularioOrigen => $composableBuilder(
    column: $table.campoFormularioOrigen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pathLocal => $composableBuilder(
    column: $table.pathLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArchivosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArchivosTable> {
  $$ArchivosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get solicitudId => $composableBuilder(
    column: $table.solicitudId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get formato =>
      $composableBuilder(column: $table.formato, builder: (column) => column);

  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tamanoBytes => $composableBuilder(
    column: $table.tamanoBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get campoFormularioOrigen => $composableBuilder(
    column: $table.campoFormularioOrigen,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pathLocal =>
      $composableBuilder(column: $table.pathLocal, builder: (column) => column);

  GeneratedColumn<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );
}

class $$ArchivosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArchivosTable,
          ArchivoRow,
          $$ArchivosTableFilterComposer,
          $$ArchivosTableOrderingComposer,
          $$ArchivosTableAnnotationComposer,
          $$ArchivosTableCreateCompanionBuilder,
          $$ArchivosTableUpdateCompanionBuilder,
          (
            ArchivoRow,
            BaseReferences<_$AppDatabase, $ArchivosTable, ArchivoRow>,
          ),
          ArchivoRow,
          PrefetchHooks Function()
        > {
  $$ArchivosTableTableManager(_$AppDatabase db, $ArchivosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ArchivosTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ArchivosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ArchivosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> solicitudId = const Value.absent(),
                Value<String?> nombre = const Value.absent(),
                Value<String?> formato = const Value.absent(),
                Value<String?> contentType = const Value.absent(),
                Value<int> tamanoBytes = const Value.absent(),
                Value<String?> campoFormularioOrigen = const Value.absent(),
                Value<String?> pathLocal = const Value.absent(),
                Value<DateTime?> actualizadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArchivosCompanion(
                id: id,
                solicitudId: solicitudId,
                nombre: nombre,
                formato: formato,
                contentType: contentType,
                tamanoBytes: tamanoBytes,
                campoFormularioOrigen: campoFormularioOrigen,
                pathLocal: pathLocal,
                actualizadoEn: actualizadoEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> solicitudId = const Value.absent(),
                Value<String?> nombre = const Value.absent(),
                Value<String?> formato = const Value.absent(),
                Value<String?> contentType = const Value.absent(),
                Value<int> tamanoBytes = const Value.absent(),
                Value<String?> campoFormularioOrigen = const Value.absent(),
                Value<String?> pathLocal = const Value.absent(),
                Value<DateTime?> actualizadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArchivosCompanion.insert(
                id: id,
                solicitudId: solicitudId,
                nombre: nombre,
                formato: formato,
                contentType: contentType,
                tamanoBytes: tamanoBytes,
                campoFormularioOrigen: campoFormularioOrigen,
                pathLocal: pathLocal,
                actualizadoEn: actualizadoEn,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ArchivosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArchivosTable,
      ArchivoRow,
      $$ArchivosTableFilterComposer,
      $$ArchivosTableOrderingComposer,
      $$ArchivosTableAnnotationComposer,
      $$ArchivosTableCreateCompanionBuilder,
      $$ArchivosTableUpdateCompanionBuilder,
      (ArchivoRow, BaseReferences<_$AppDatabase, $ArchivosTable, ArchivoRow>),
      ArchivoRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SolicitudesTableTableManager get solicitudes =>
      $$SolicitudesTableTableManager(_db, _db.solicitudes);
  $$TramitesTableTableManager get tramites =>
      $$TramitesTableTableManager(_db, _db.tramites);
  $$FormulariosCacheTableTableManager get formulariosCache =>
      $$FormulariosCacheTableTableManager(_db, _db.formulariosCache);
  $$DocumentosKitCacheTableTableManager get documentosKitCache =>
      $$DocumentosKitCacheTableTableManager(_db, _db.documentosKitCache);
  $$OutboxOperacionesTableTableManager get outboxOperaciones =>
      $$OutboxOperacionesTableTableManager(_db, _db.outboxOperaciones);
  $$ArchivosTableTableManager get archivos =>
      $$ArchivosTableTableManager(_db, _db.archivos);
}
