import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_provider.dart';

/// Lee la base de datos local y devuelve el ID del único usuario activo.
final localUserIdProvider = FutureProvider<String?>((ref) async {
  final db = await DatabaseProvider.db.database;
  final List<Map<String, dynamic>> users = await db.query('users', limit: 1);

  if (users.isNotEmpty) {
    return users.first['id'] as String;
  }
  return null;
});
