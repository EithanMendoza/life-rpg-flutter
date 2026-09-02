import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_provider.dart';
import '../models/user.dart';
import '../../tracker/use_cases/prescribe_odysseus_contract_use_case.dart'; // Para OdysseusContract
import 'auth_db_initializer.dart'; // ¡Asegúrate de importar el inicializador!

class AuthLocalRepository {
  /// Inserta el usuario y su contrato clínico en una transacción atómica
  Future<void> createShadowAccountWithContract(
    User user,
    OdysseusContract contract,
  ) async {
    final db = await DatabaseProvider.db.database;
    await AuthDbInitializer.initializeSchema(db);

    // Ejecución Atómica: Si falla una tabla, se hace Rollback automático de todas
    await db.transaction((txn) async {
      // Paso A: Crear registro de la Shadow Account
      await txn.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Paso C: Batch Insert para Hábitos y Misiones
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
