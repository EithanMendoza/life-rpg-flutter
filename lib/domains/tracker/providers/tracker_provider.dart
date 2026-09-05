import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/tracker_local_repository.dart';
import '../use_cases/tracker_use_cases.dart';
import '../models/habit_draft_state.dart';
import 'day_zero_provider.dart';

// 1. INYECCIÓN DE DEPENDENCIAS BASE
final trackerLocalRepositoryProvider = Provider<TrackerLocalRepository>((ref) {
  return const TrackerLocalRepository();
});

final trackerUseCasesProvider = Provider<TrackerUseCases>((ref) {
  final repository = ref.watch(trackerLocalRepositoryProvider);
  return TrackerUseCases(repository);
});

// 2. LECTURA REACTIVA DE DATOS
final habitsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      userId,
    ) async {
      final repository = ref.read(trackerLocalRepositoryProvider);
      return repository.getDailyHabits(userId);
    });

// ============================================================================
// 3. CONTROLADOR DE OPERACIONES ASÍNCRONAS (TrackerController)
// ============================================================================

final trackerControllerProvider =
    AsyncNotifierProvider<TrackerController, void>(() {
      return TrackerController();
    });

class TrackerController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createNewHabit({
    required String userId,
    required String title,
    String? anchorEvent,
    required String recurrencePattern,
    required bool isRecovery,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(trackerUseCasesProvider)
          .createNewHabit(
            userId: userId,
            title: title,
            anchorEvent: anchorEvent,
            recurrencePattern: recurrencePattern,
            isRecovery: isRecovery,
          );
      ref.invalidate(habitsProvider(userId));
    });
  }

  Future<void> registerAction({
    required String userId,
    required String actionType,
    required int timezoneOffset,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(trackerUseCasesProvider)
          .logAction(
            userId: userId,
            actionType: actionType,
            timezoneOffset: timezoneOffset,
          );
    });
  }

  Future<void> injectTutorialDamage(String userId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final timezoneOffset = DateTime.now().timeZoneOffset.inHours;
      await ref
          .read(trackerUseCasesProvider)
          .logAction(
            userId: userId,
            actionType: 'tutorial_hp_loss',
            timezoneOffset: timezoneOffset,
          );
    });
  }

  Future<void> purgeTutorialAndTransition({required String userId}) async {
    state = const AsyncValue.loading();
    try {
      // 🛡️ Llamamos directamente al Repositorio para asegurar que el borrado físico
      // ocurra sin depender de un Caso de Uso que podría estar incompleto.
      await ref.read(trackerLocalRepositoryProvider).purgeTutorialData(userId);

      // Invalidamos el estado para que la pantalla principal se recargue
      ref.invalidate(dayZeroProvider);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      print(
        '❌ [TrackerController] Error crítico al purgar el tutorial: $error',
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> commitAction({required String habitId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // ✅ CORRECCIÓN
      await ref.read(trackerUseCasesProvider).commitAction(habitId: habitId);
    });
  }

  Future<void> undoAction({required String habitId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // ✅ CORRECCIÓN
      await ref.read(trackerUseCasesProvider).undoAction(habitId: habitId);
    });
  }
}

// ============================================================================
// 4. CONTROLADOR DE ESTADO EN MEMORIA (HabitDraftController - Riverpod 3.x)
// ============================================================================

final habitDraftControllerProvider =
    NotifierProvider.autoDispose<HabitDraftController, HabitDraftState>(
      HabitDraftController.new,
    );

class HabitDraftController extends Notifier<HabitDraftState> {
  @override
  HabitDraftState build() {
    return const HabitDraftState();
  }

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void toggleTriggerType(String type) {
    state = state.copyWith(
      triggerType: type,
      anchorEvent: type == 'time' ? null : state.anchorEvent,
      triggerTime: type == 'event' ? null : state.triggerTime,
    );
  }

  void updateAnchorEvent(String event) {
    state = state.copyWith(anchorEvent: event);
  }

  void updateTriggerTime(String time) {
    state = state.copyWith(triggerTime: time);
  }

  void updateDuration(int? minutes) {
    state = state.copyWith(durationMinutes: minutes);
  }

  void setPriority(String priority) {
    state = state.copyWith(priorityLevel: priority);
  }

  void setRecurrencePattern(String pattern) {
    state = state.copyWith(recurrencePattern: pattern);
  }

  Future<bool> saveHabit(
    String userId, {
    String? tutorialStepIdToRemove,
  }) async {
    if (state.title.trim().isEmpty) return false;
    if (state.triggerType == 'event' &&
        (state.anchorEvent == null || state.anchorEvent!.trim().isEmpty)) {
      return false;
    }
    if (state.triggerType == 'time' &&
        (state.triggerTime == null || state.triggerTime!.trim().isEmpty)) {
      return false;
    }

    try {
      await ref
          .read(trackerUseCasesProvider)
          .createNewHabit(
            userId: userId,
            title: state.title,
            triggerType: state.triggerType,
            anchorEvent: state.anchorEvent,
            triggerTime: state.triggerTime,
            durationMinutes: state.durationMinutes,
            priorityLevel: state.priorityLevel,
            recurrencePattern: state.recurrencePattern,
            isRecovery: false,
          );

      if (tutorialStepIdToRemove != null) {
        await ref
            .read(trackerUseCasesProvider)
            .completeTutorialStep(tutorialStepIdToRemove);
        ref.invalidate(dayZeroProvider);
      }

      ref.invalidate(habitsProvider(userId));
      return true;
    } catch (_) {
      return false;
    }
  }
}
