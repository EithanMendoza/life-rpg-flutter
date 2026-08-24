import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/database_provider.dart';

class TrackerLocalRepository {
  const TrackerLocalRepository();

  /// 1. Guardar un nuevo hábito (Lead Measure)
  /// Realiza una inserción directa y segura en la tabla local 'habits'.
  Future<void> insertHabit(String userId, String title) async {
    final db = await DatabaseProvider.db.database;
    const uuid = Uuid();
    final habitId = uuid.v4();

    await db.insert('habits', {
      'id': habitId,
      'user_id': userId,
      'title': title,
      'base_xp': 10,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getHabits(String userId) async {
    final db = await DatabaseProvider.db.database;

    // 1. Obtenemos la fecha local de hoy en formato 'YYYY-MM-DD'
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);

    // 2. Usamos date(..., 'localtime') para que SQLite compare contra la fecha local real
    final List<Map<String, dynamic>> results = await db.rawQuery(
      '''
    SELECT 
      h.id, 
      h.user_id, 
      h.title, 
      h.base_xp, 
      h.is_active, 
      h.created_at,
      (
        SELECT COUNT(1) 
        FROM action_logs al 
        WHERE al.action_type = 'habit_completed:' || h.id 
          AND date(al.client_timestamp, 'localtime') = ?
      ) as completed_count
    FROM habits h
    WHERE h.user_id = ? AND h.is_active = 1
    ORDER BY h.created_at DESC
  ''',
      [todayStr, userId],
    );

    return results;
  }

  /// 2. Registrar acción completada (Acción inmutable para la tabla action_logs)
  /// ADVERTENCIA PM: Esta inserción es síncrona al disco local y sirve como base
  /// para que posteriormente el Patrón Observador de Gamificación procese la recompensa.
  Future<void> logAction({
    required String userId,
    required String actionType,
    required int timezoneOffset,
  }) async {
    final db = await DatabaseProvider.db.database;
    const uuid = Uuid();
    final logId = uuid.v4();

    await db.insert('action_logs', {
      'id': logId,
      'user_id': userId,
      'action_type': actionType,
      'client_timestamp': DateTime.now().toUtc().toIso8601String(),
      'executed_timezone_offset': timezoneOffset,
      'xp_rewarded': 10, // Recompensa base temporal
      'escrow_xp': 0,
      'sync_status':
          'pending', // Pendiente de sincronizar con el servidor Node.js
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
