import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/tracker_local_repository.dart';

/// 1. Provider que expone el repositorio local de forma aislada.
final trackerLocalRepositoryProvider = Provider<TrackerLocalRepository>((ref) {
  return const TrackerLocalRepository();
});

/// 2. Provider de LECTURA: Obtiene la lista de hábitos desde SQLite de forma reactiva.
final habitsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      userId,
    ) async {
      final repository = ref.read(trackerLocalRepositoryProvider);
      return await repository.getHabits(userId);
    });

/// 3. Controller de ESCRITURA: Gestiona las operaciones de modificación (crear hábitos, registrar acciones).
final trackerControllerProvider =
    AsyncNotifierProvider<TrackerController, void>(() {
      return TrackerController();
    });

class TrackerController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Inicialización del estado (vacío por defecto)
  }

  /// Inserta un nuevo hábito y refresca automáticamente la lista en pantalla
  Future<void> createNewHabit(String userId, String title) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(trackerLocalRepositoryProvider);
      await repository.insertHabit(userId, title);

      // Truco clave de Riverpod: Invalidamos el provider de lectura
      // para que la UI se entere de que hay un nuevo hábito y se redibuje al instante.
      ref.invalidate(habitsProvider(userId));
    });
  }

  /// Registra una acción completada en el disco local
  Future<void> registerAction({
    required String userId,
    required String actionType,
    required int timezoneOffset,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(trackerLocalRepositoryProvider);
      await repository.logAction(
        userId: userId,
        actionType: actionType,
        timezoneOffset: timezoneOffset,
      );
    });
  }
}
