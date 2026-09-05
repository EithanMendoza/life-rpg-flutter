import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  // Patrón Singleton: Única fuente de verdad para la conexión SQLite
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
      version: 4, // Subimos a V4 para consolidar la tabla users de forma segura
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Configuración de bajo nivel de SQLite
  Future<void> _onConfigure(Database db) async {
    await db.rawQuery('PRAGMA journal_mode=WAL;');
    await db.rawQuery('PRAGMA foreign_keys = ON;');
  }

  // El Mapa Topológico Real: Aquí nacen TODAS las tablas de la app
  Future<void> _onCreate(Database db, int version) async {
    // --- DOMINIO: AUTH ---
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        oauth_id TEXT UNIQUE,
        xp INTEGER NOT NULL DEFAULT 0,
        gold_balance INTEGER NOT NULL DEFAULT 0,
        day_start_time TEXT NOT NULL DEFAULT '00:00:00',
        target_sleep_time TEXT NOT NULL DEFAULT '23:00:00',
        archetype TEXT,
        primary_vulnerability TEXT,
        account_status TEXT NOT NULL DEFAULT 'active',
        shields INTEGER NOT NULL DEFAULT 0,
        is_sleep_mode_active INTEGER NOT NULL DEFAULT 0,
        created_at TEXT
      )
    ''');

    // --- DOMINIO: TRACKER ---
    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        base_xp INTEGER NOT NULL DEFAULT 10,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        habit_type TEXT NOT NULL DEFAULT 'standard',
        anchor_event TEXT,
        recurrence_pattern TEXT NOT NULL DEFAULT '1,2,3,4,5,6,7',
        is_recovery INTEGER NOT NULL DEFAULT 0,
        trigger_type TEXT NOT NULL DEFAULT 'event',
        trigger_time TEXT,
        duration_minutes INTEGER,
        priority_level TEXT NOT NULL DEFAULT 'medium'
      )
    ''');

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

    await db.execute('''
      CREATE TABLE if_then_missions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        trigger_condition TEXT NOT NULL,
        action_response TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // Migraciones Centralizadas
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migración V1.5 - Hábitos
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE habits ADD COLUMN habit_type TEXT NOT NULL DEFAULT 'standard';",
      );
      await db.execute("ALTER TABLE habits ADD COLUMN anchor_event TEXT;");
      await db.execute(
        "ALTER TABLE habits ADD COLUMN recurrence_pattern TEXT NOT NULL DEFAULT '1,2,3,4,5,6,7';",
      );
      await db.execute(
        "ALTER TABLE habits ADD COLUMN is_recovery INTEGER NOT NULL DEFAULT 0;",
      );
    }

    // Migración V3 - Gatillos Híbridos y Prioridad
    if (oldVersion < 3) {
      await db.execute(
        "ALTER TABLE habits ADD COLUMN trigger_type TEXT NOT NULL DEFAULT 'event';",
      );
      await db.execute("ALTER TABLE habits ADD COLUMN trigger_time TEXT;");
      await db.execute(
        "ALTER TABLE habits ADD COLUMN duration_minutes INTEGER;",
      );
      await db.execute(
        "ALTER TABLE habits ADD COLUMN priority_level TEXT NOT NULL DEFAULT 'medium';",
      );
    }

    // Migración V4 - Absorción de las migraciones huérfanas de Auth
    if (oldVersion < 4) {
      // Intentamos crear la tabla users por si nunca se inicializó con el script huérfano
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id TEXT PRIMARY KEY,
          oauth_id TEXT UNIQUE,
          xp INTEGER NOT NULL DEFAULT 0,
          gold_balance INTEGER NOT NULL DEFAULT 0,
          account_status TEXT NOT NULL DEFAULT 'active'
        )
      ''');

      final tableInfo = await db.rawQuery("PRAGMA table_info(users)");
      final currentColumns = tableInfo
          .map((col) => col['name'] as String)
          .toList();

      if (!currentColumns.contains('shields'))
        await db.execute(
          "ALTER TABLE users ADD COLUMN shields INTEGER NOT NULL DEFAULT 0;",
        );
      if (!currentColumns.contains('is_sleep_mode_active'))
        await db.execute(
          "ALTER TABLE users ADD COLUMN is_sleep_mode_active INTEGER NOT NULL DEFAULT 0;",
        );
      if (!currentColumns.contains('archetype'))
        await db.execute("ALTER TABLE users ADD COLUMN archetype TEXT;");
      if (!currentColumns.contains('primary_vulnerability'))
        await db.execute(
          "ALTER TABLE users ADD COLUMN primary_vulnerability TEXT;",
        );
      if (!currentColumns.contains('target_sleep_time'))
        await db.execute(
          "ALTER TABLE users ADD COLUMN target_sleep_time TEXT NOT NULL DEFAULT '23:00:00';",
        );
      if (!currentColumns.contains('day_start_time'))
        await db.execute(
          "ALTER TABLE users ADD COLUMN day_start_time TEXT NOT NULL DEFAULT '00:00:00';",
        );
      if (!currentColumns.contains('created_at'))
        await db.execute("ALTER TABLE users ADD COLUMN created_at TEXT;");
    }
  }
}
