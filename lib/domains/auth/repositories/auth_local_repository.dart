import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_provider.dart';
import '../models/user.dart';

// ADVERTENCIA ARQUITECTÓNICA: Fuga de dominio.
// AuthLocalRepository no debería conocer el OdysseusContract (Dominio Tracker).
// TODO: En la Fase 2, esta transacción debe moverse a un Provider u Orquestador.
import '../../tracker/use_cases/prescribe_odysseus_contract_use_case.dart';

class AuthLocalRepository {
  /// Inserta el usuario y su contrato clínico en una transacción atómica
  Future<void> createShadowAccountWithContract(
    User user,
    OdysseusContract contract,
  ) async {
    // 1. Obtenemos la conexión única y centralizada.
    // Ya NO necesitamos inicializar el esquema aquí.
    final db = await DatabaseProvider.db.database;

    // Ejecución Atómica: Si falla una inserción, se revierte todo (Rollback)
    await db.transaction((txn) async {
      // Paso A: Crear registro del Usuario (Esto SÍ le pertenece a este repositorio)
      await txn.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Paso B: Batch Insert para Hábitos y Misiones (Esto NO le pertenece a este repositorio)
      final batch = txn.batch();

      for (final habit in contract.habits) {
        batch.insert('habits', habit.toMap());
      }

      for (final mission in contract.missions) {
        batch.insert('if_then_missions', mission.toMap());
      }

      // Ejecutar lote completo
      await batch.commit(noResult: true);
    });
  }
}
