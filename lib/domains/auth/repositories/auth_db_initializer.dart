import 'package:sqflite/sqflite.dart';

class AuthDbInitializer {
  static Future<void> initializeSchema(Database db) async {
    // 1. Creación Base con el esquema completo del Contrato Clínico
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
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

    // 2. Migraciones Dinámicas para columnas nuevas (por si la tabla ya existía a medias)
    final tableInfo = await db.rawQuery("PRAGMA table_info(users)");
    final currentColumns = tableInfo
        .map((col) => col['name'] as String)
        .toList();

    if (!currentColumns.contains('shields')) {
      await db.execute(
        "ALTER TABLE users ADD COLUMN shields INTEGER NOT NULL DEFAULT 0;",
      );
    }
    if (!currentColumns.contains('is_sleep_mode_active')) {
      await db.execute(
        "ALTER TABLE users ADD COLUMN is_sleep_mode_active INTEGER NOT NULL DEFAULT 0;",
      );
    }
    if (!currentColumns.contains('archetype')) {
      await db.execute("ALTER TABLE users ADD COLUMN archetype TEXT;");
      await db.execute(
        "ALTER TABLE users ADD COLUMN primary_vulnerability TEXT;",
      );
      await db.execute(
        "ALTER TABLE users ADD COLUMN target_sleep_time TEXT NOT NULL DEFAULT '23:00:00';",
      );
      await db.execute("ALTER TABLE users ADD COLUMN created_at TEXT;");
    }
  }
}
