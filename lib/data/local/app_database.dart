import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Tablas (modelo B híbrido): columnas reales para lo que se lista/filtra +
// una columna JSON para lo anidado (historial, respuestas). Encaja con un
// backend documental (Mongo) sin tener que normalizar a fondo.
// ---------------------------------------------------------------------------

/// Solicitudes del usuario. Las columnas sirven para listar; `detalleJson`
/// guarda el SolicitudDetalle completo (historial incluido) cuando se trajo.
@DataClassName('SolicitudRow')
class Solicitudes extends Table {
  TextColumn get id => text()();
  TextColumn get tramiteId => text().nullable()();
  TextColumn get tramiteNombre => text().nullable()();
  TextColumn get estado => text().nullable()();
  DateTimeColumn get fechaCreacion => dateTime().nullable()();
  DateTimeColumn get fechaFinalizacion => dateTime().nullable()();

  /// JSON crudo del detalle completo (respuestas, historial por depto, etc.).
  TextColumn get detalleJson => text().nullable()();

  /// true si es una solicitud creada offline que todavía no se sincronizó.
  BoolColumn get pendienteSync => boolean().withDefault(const Constant(false))();

  /// clientId (UUID) de la operación que la creó (para enlazarla con el Outbox).
  TextColumn get clientId => text().nullable()();

  /// Motivo del fallo de sincronización (null = sin error). Si está seteado,
  /// la solicitud quedó en estado "Error" y no se reintenta sola.
  TextColumn get syncError => text().nullable()();

  DateTimeColumn get actualizadoEn => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cola de escrituras pendientes (Outbox Pattern). FIFO por `id`.
@DataClassName('OutboxRow')
class OutboxOperaciones extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// UUID idempotente que se manda al backend para deduplicar reintentos.
  TextColumn get clientId => text()();

  /// Tipo de operación, ej: "crear_solicitud".
  TextColumn get tipo => text()();

  /// Datos de la operación (tramiteId, respuestas, archivos locales…).
  TextColumn get payloadJson => text()();

  /// "pendiente" | "error".
  TextColumn get estado => text().withDefault(const Constant('pendiente'))();
  IntColumn get intentos => integer().withDefault(const Constant(0))();
  TextColumn get ultimoError => text().nullable()();
  DateTimeColumn get creadoEn => dateTime().nullable()();
}

/// Caché de metadata de archivos (+ ruta local si ya se descargó, para verlos
/// offline). El binario vive en el filesystem, no acá.
@DataClassName('ArchivoRow')
class Archivos extends Table {
  TextColumn get id => text()();
  TextColumn get solicitudId => text().nullable()();
  TextColumn get nombre => text().nullable()();
  TextColumn get formato => text().nullable()();
  TextColumn get contentType => text().nullable()();
  IntColumn get tamanoBytes => integer().withDefault(const Constant(0))();
  TextColumn get campoFormularioOrigen => text().nullable()();

  /// Ruta del archivo descargado en el dispositivo (null = no descargado).
  TextColumn get pathLocal => text().nullable()();
  DateTimeColumn get actualizadoEn => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Catálogo de tipos de trámite disponibles.
@DataClassName('TramiteRow')
class Tramites extends Table {
  TextColumn get id => text()();
  TextColumn get nombre => text().nullable()();
  TextColumn get descripcion => text().nullable()();
  TextColumn get formularioSolicitanteId => text().nullable()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();

  /// JSON crudo del TramiteDisponible (requisitos, etc.).
  TextColumn get json => text()();
  DateTimeColumn get actualizadoEn => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Caché on-demand del formulario de un trámite (JSON del FormularioTemplate).
@DataClassName('FormularioCacheRow')
class FormulariosCache extends Table {
  TextColumn get id => text()();
  TextColumn get json => text()();
  DateTimeColumn get actualizadoEn => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Caché on-demand del kit de documentos de un trámite (JSON de la lista).
@DataClassName('DocumentoKitCacheRow')
class DocumentosKitCache extends Table {
  TextColumn get tramiteId => text()();
  TextColumn get json => text()();
  DateTimeColumn get actualizadoEn => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {tramiteId};
}

// ---------------------------------------------------------------------------
// Base de datos
// ---------------------------------------------------------------------------

@DriftDatabase(
  tables: [
    Solicitudes,
    Tramites,
    FormulariosCache,
    DocumentosKitCache,
    OutboxOperaciones,
    Archivos,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_abrirConexion());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(solicitudes, solicitudes.pendienteSync);
            await m.addColumn(solicitudes, solicitudes.clientId);
            await m.createTable(outboxOperaciones);
            await m.createTable(archivos);
          }
          if (from < 3) {
            await m.addColumn(solicitudes, solicitudes.syncError);
          }
        },
      );
}

LazyDatabase _abrirConexion() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/tramites.db');
    return NativeDatabase.createInBackground(file);
  });
}
