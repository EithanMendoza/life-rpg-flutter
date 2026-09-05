import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tracker_provider.dart';
import '../../../../core/providers/session_provider.dart'; // Puente a la identidad real

class DayZeroNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    // 1. Escuchamos de forma reactiva el ID real del usuario
    final userId = await ref.watch(localUserIdProvider.future);

    if (userId == null) return [];
    return _fetchTutorialSteps(userId);
  }

  Future<List<Map<String, dynamic>>> _fetchTutorialSteps(String userId) async {
    final repository = ref.read(trackerLocalRepositoryProvider);
    return await repository.getTutorialSteps(userId);
  }

  /// Método para recargar la lista al completar o eliminar un paso del tutorial
  Future<void> refreshTutorial() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Leemos el ID real sincrónicamente para el refresco
      final userId = ref.read(localUserIdProvider).value;
      if (userId == null) return [];
      return _fetchTutorialSteps(userId);
    });
  }
}

final dayZeroProvider =
    AsyncNotifierProvider<DayZeroNotifier, List<Map<String, dynamic>>>(() {
      return DayZeroNotifier();
    });
