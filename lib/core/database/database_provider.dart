import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  // Patrón Singleton para garantizar una única conexión viva a la base de datos
  // y evitar bloqueos de archivo (File Locks) en SQLite.
  DatabaseProvider._();
  static final DatabaseProvider db = DatabaseProvider._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'liferpg_local.db');

    return await openDatabase(
      path,
      version: 1,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
  }

  // ADVERTENCIA PM (ADR-001): Configuración de bajo nivel de SQLite
  Future<void> _onConfigure(Database db) async {
    // Al devolver resultados, PRAGMA requiere obligatoriamente rawQuery en sqflite
    await db.rawQuery('PRAGMA journal_mode=WAL;');

    // Activamos el soporte de llaves foráneas.
    await db.rawQuery('PRAGMA foreign_keys = ON;');
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Tabla: habits (Acciones recurrentes de baja fricción)
    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        base_xp INTEGER NOT NULL DEFAULT 10,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // 2. Tabla: action_logs (El historial inmutable y base del Escrow XP)
    // ADVERTENCIA PM: client_timestamp y executed_timezone_offset son obligatorios
    // para el algoritmo de corte de caja del servidor.
    await db.execute('''
      CREATE TABLE action_logs (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        action_type TEXT NOT NULL,
        client_timestamp TEXT NOT NULL,
        executed_timezone_offset INTEGER NOT NULL,
        xp_rewarded INTEGER NOT NULL DEFAULT 0,
        escrow_xp INTEGER NOT NULL DEFAULT 0,
        sync_status TEXT NOT NULL DEFAULT 'pending'
      )
    ''');

    // 3. Tabla: if_then_missions (Modelo de Gollwitzer)
    await db.execute('''
      CREATE TABLE if_then_missions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        trigger_condition TEXT NOT NULL,
        action_response TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Nota de Arquitectura: La tabla 'users' o 'shadow_accounts' la manejaremos
    // en un script de inicialización independiente para mantener la separación de responsabilidades.
  }
}
