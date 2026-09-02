import 'package:sqflite/sqflite.dart';

import '../../../core/database/database_provider.dart';
import '../models/habit.dart';

class TrackerLocalRepository {
  const TrackerLocalRepository();

  Future<void> insertHabit(Habit habit) async {
    final db = await DatabaseProvider.db.database;
    await db.insert(
      'habits',
      habit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Habit>> getHabits() async {
    final db = await DatabaseProvider.db.database;
    final List<Map<String, dynamic>> maps = await db.query('habits');
    return List.generate(maps.length, (i) => Habit.fromMap(maps[i]));
  }

  Future<List<Habit>> getAllHabits() async {
    final db = await DatabaseProvider.db.database;
    final List<Map<String, dynamic>> maps = await db.query('habits');
    return List.generate(maps.length, (i) => Habit.fromMap(maps[i]));
  }

  /// Obtiene los hábitos del día.
  /// Utiliza subconsultas para garantizar EXACTAMENTE 1 fila por hábito,
  /// extrayendo solo el último registro del action_log para el temporizador.
  Future<List<Map<String, dynamic>>> getDailyHabits(String userId) async {
    final db = await DatabaseProvider.db.database;

    final List<Map<String, dynamic>> results = await db.rawQuery(
      '''
      SELECT 
        h.*,
        
        -- 1. Recuperamos el conteo total para saber si ya se completó hoy
        (
          SELECT COUNT(1) 
          FROM action_logs al 
          WHERE al.action_type = 'habit_completed:' || h.id 
            AND date(al.client_timestamp, 'localtime') = date('now', 'localtime')
        ) as completed_count,
        
        -- 2. Recuperamos el estado de sincronización del ÚLTIMO registro
        (
          SELECT al.sync_status 
          FROM action_logs al 
          WHERE al.action_type = 'habit_completed:' || h.id 
            AND date(al.client_timestamp, 'localtime') = date('now', 'localtime')
          ORDER BY al.client_timestamp DESC 
          LIMIT 1
        ) as current_sync_status,
        
        -- 3. Recuperamos el timestamp del ÚLTIMO registro para el cronómetro OOM Killer
        (
          SELECT al.client_timestamp 
          FROM action_logs al 
          WHERE al.action_type = 'habit_completed:' || h.id 
            AND date(al.client_timestamp, 'localtime') = date('now', 'localtime')
          ORDER BY al.client_timestamp DESC 
          LIMIT 1
        ) as log_timestamp
        
      FROM habits h
      WHERE h.user_id = ? AND h.is_active = 1
      ORDER BY h.created_at DESC
    ''',
      [userId],
    );

    return results;
  }

  /// Repositorio purgado de responsabilidades lógicas. Solo acepta y persiste.
  Future<void> insertActionLog({
    required String logId,
    required String userId,
    required String actionType,
    required String clientTimestamp,
    required int executedTimezoneOffset,
    required int xpRewarded,
    required int escrowXp,
    required String syncStatus,
  }) async {
    final db = await DatabaseProvider.db.database;
    await db.insert('action_logs', {
      'id': logId,
      'user_id': userId,
      'action_type': actionType,
      'client_timestamp': clientTimestamp,
      'executed_timezone_offset': executedTimezoneOffset,
      'xp_rewarded': xpRewarded,
      'escrow_xp': escrowXp,
      'sync_status': syncStatus,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// NUEVO: Confirma la acción después de 15 minutos
  Future<void> commitAction(String habitId) async {
    final db = await DatabaseProvider.db.database;
    await db.rawUpdate(
      '''
      UPDATE action_logs 
      SET sync_status = 'pending' 
      WHERE action_type = ? AND sync_status = 'pending_undo'
      ''',
      ['habit_completed:$habitId'],
    );
  }

  /// NUEVO: Borrado físico si el usuario presiona "Deshacer"
  Future<void> undoAction(String habitId) async {
    final db = await DatabaseProvider.db.database;
    await db.delete(
      'action_logs',
      where: 'action_type = ? AND sync_status = ?',
      whereArgs: ['habit_completed:$habitId', 'pending_undo'],
    );
  }
}
