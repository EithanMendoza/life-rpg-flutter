import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';
import '../repositories/tracker_local_repository.dart';
import '../models/habit.dart';

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
      return repository.getDailyHabits(userId);
    });

/// 3. Controller de ESCRITURA: Gestiona las operaciones de modificación directas.
final trackerControllerProvider =
    AsyncNotifierProvider<TrackerController, void>(() {
      return TrackerController();
    });

class TrackerController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Inicialización del estado (vacío por defecto)
  }

  /// Inserta un nuevo hábito con los metadatos de apilamiento y resiliencia
  Future<void> createNewHabit({
    required String userId,
    required String title,
    String? anchorEvent,
    required String recurrencePattern,
    required bool isRecovery,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(trackerLocalRepositoryProvider);

      final cleanAnchor = (anchorEvent != null && anchorEvent.trim().isNotEmpty)
          ? anchorEvent.trim()
          : null;

      final newHabit = Habit(
        id: const Uuid().v4(),
        userId: userId,
        title: title.trim(),
        createdAt: DateTime.now().toUtc().toIso8601String(),
        habitType: isRecovery ? 'recovery' : 'standard',
        anchorEvent: cleanAnchor,
        recurrencePattern: recurrencePattern,
        isRecovery: isRecovery,
      );

      await repository.insertHabit(newHabit);
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

  /// Confirma la acción tras 15 minutos (Soft-Commit definitivo)
  Future<void> commitAction({required String habitId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(trackerLocalRepositoryProvider);
      await repository.commitAction(habitId);
      // No necesitamos invalidar aquí porque la UI ya lo hace, pero es buena práctica
    });
  }

  /// Revierte la acción física en SQLite
  Future<void> undoAction({required String habitId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(trackerLocalRepositoryProvider);
      await repository.undoAction(habitId);
    });
  }
}

// ============================================================================
// NUEVO: ESTADO Y CONTROLADOR PARA EL FORMULARIO "MAD LIBS" (DRAFT)
// ============================================================================

class HabitDraftState {
  final String title;
  final String triggerType;
  final String? anchorEvent;
  final String? triggerTime;
  final int? durationMinutes;
  final String priorityLevel;
  final String recurrencePattern;

  const HabitDraftState({
    this.title = '',
    this.triggerType = 'event',
    this.anchorEvent,
    this.triggerTime,
    this.durationMinutes,
    this.priorityLevel = 'medium',
    this.recurrencePattern = '1,2,3,4,5,6,7',
  });

  HabitDraftState copyWith({
    String? title,
    String? triggerType,
    String? anchorEvent,
    String? triggerTime,
    int? durationMinutes,
    String? priorityLevel,
    String? recurrencePattern,
  }) {
    return HabitDraftState(
      title: title ?? this.title,
      triggerType: triggerType ?? this.triggerType,
      anchorEvent: anchorEvent ?? this.anchorEvent,
      triggerTime: triggerTime ?? this.triggerTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
    );
  }
}

/// Usamos StateNotifierProvider para máxima compatibilidad con el compilador de Dart
final habitDraftControllerProvider =
    StateNotifierProvider.autoDispose<HabitDraftController, HabitDraftState>((
      ref,
    ) {
      return HabitDraftController(ref);
    });

class HabitDraftController extends StateNotifier<HabitDraftState> {
  final Ref ref; // Inyectamos ref manualmente para que no marque error

  HabitDraftController(this.ref) : super(const HabitDraftState());

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

  Future<bool> saveHabit(String userId) async {
    // Validaciones
    if (state.title.trim().isEmpty) return false;

    if (state.triggerType == 'event' &&
        (state.anchorEvent == null || state.anchorEvent!.trim().isEmpty)) {
      return false;
    }

    if (state.triggerType == 'time' &&
        (state.triggerTime == null || state.triggerTime!.trim().isEmpty)) {
      return false;
    }

    final newHabit = Habit(
      id: const Uuid().v4(),
      userId: userId,
      title: state.title.trim(),
      createdAt: DateTime.now().toUtc().toIso8601String(),
      triggerType: state.triggerType,
      anchorEvent: state.anchorEvent?.trim(),
      triggerTime: state.triggerTime?.trim(),
      durationMinutes: state.durationMinutes,
      priorityLevel: state.priorityLevel,
      recurrencePattern: state.recurrencePattern,
      habitType: 'standard', // Valor por defecto seguro
      isRecovery: false, // Valor por defecto seguro
    );

    final repository = ref.read(trackerLocalRepositoryProvider);
    await repository.insertHabit(newHabit);

    // Forzamos el refresco de la UI de inmediato
    ref.invalidate(habitsProvider(userId));

    return true;
  }

  /// Confirma el hábito tras pasar la ventana de reversibilidad (Soft-Commit a Definitivo)
  Future<void> commitAction({required String habitId}) async {
    try {
      // Instancia del repositorio (ajusta si usas un Provider para el repositorio, ej: ref.read(repositoryProvider))
      const repository = TrackerLocalRepository();

      await repository.commitAction(habitId);

      // Opcional: Actualizar el estado local si mantienes una lista en memoria
      // state = const AsyncValue.data(...);
    } catch (e, st) {
      // Manejo de errores (puedes enviar esto a Sentry/Crashlytics)
      print('Error al confirmar acción: $e');
    }
  }

  /// Revierte el hábito (Soft Delete) si el usuario presiona "Deshacer"
  Future<void> undoAction({required String habitId}) async {
    try {
      const repository = TrackerLocalRepository();

      await repository.undoAction(habitId);

      // Opcional: Actualizar el estado local si es necesario
    } catch (e, st) {
      print('Error al deshacer acción: $e');
    }
  }
}
