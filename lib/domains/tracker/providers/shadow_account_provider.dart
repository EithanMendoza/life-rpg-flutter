import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';

/// Provider ligero para extraer los datos del diagnostico de la Shadow Account.
/// Utilizado principalmente por formularios del Dia Cero para pre-llenar
/// campos con la vulnerabilidad registrada durante el onboarding.
final shadowAccountProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final db = await DatabaseProvider.db.database;
  final users = await db.query('users', limit: 1);
  return users.isNotEmpty ? users.first : null;
});
