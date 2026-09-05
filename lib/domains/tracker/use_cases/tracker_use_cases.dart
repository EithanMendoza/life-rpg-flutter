import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../repositories/tracker_local_repository.dart';

class TrackerUseCases {
  final TrackerLocalRepository _repository;

  const TrackerUseCases(this._repository);

  Future<void> createNewHabit({
    required String userId,
    required String title,
    String? anchorEvent,
    required String recurrencePattern,
    required bool isRecovery,
    String triggerType = 'event',
    String? triggerTime,
    int? durationMinutes,
    String priorityLevel = 'medium',
  }) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) throw ArgumentError('El título es obligatorio');

    final cleanAnchor = (anchorEvent != null && anchorEvent.trim().isNotEmpty)
        ? anchorEvent.trim()
        : null;

    final newHabit = Habit(
      id: const Uuid().v4(),
      userId: userId,
      title: cleanTitle,
      createdAt: DateTime.now().toUtc().toIso8601String(),
      habitType: isRecovery ? 'recovery' : 'standard',
      triggerType: triggerType,
      anchorEvent: cleanAnchor,
      triggerTime: triggerTime?.trim(),
      durationMinutes: durationMinutes,
      priorityLevel: priorityLevel,
      recurrencePattern: recurrencePattern,
      isRecovery: isRecovery,
    );

    await _repository.insertHabit(newHabit);
  }

  Future<void> logAction({
    required String userId,
    required String actionType,
    required int timezoneOffset,
  }) async {
    // La lógica de negocio (asignación de XP inicial y creación de metadatos) ocurre aquí
    await _repository.insertActionLog(
      logId: const Uuid().v4(),
      userId: userId,
      actionType: actionType,
      clientTimestamp: DateTime.now().toUtc().toIso8601String(),
      executedTimezoneOffset: timezoneOffset,
      xpRewarded: 10,
      escrowXp: 0,
      syncStatus: 'pending_undo',
    );
  }

  Future<void> createIfThenMission({
    required String userId,
    required String trigger,
    required String response,
  }) async {
    final cleanTrigger = trigger.trim();
    final cleanResponse = response.trim();

    if (cleanTrigger.isEmpty || cleanResponse.isEmpty) {
      throw ArgumentError('Campos incompletos');
    }

    await _repository.insertIfThenMission(
      const Uuid().v4(),
      userId,
      cleanTrigger,
      cleanResponse,
    );
  }

  // --- NUEVAS FUNCIONES DELEGADAS ---

  Future<void> commitAction({required String habitId}) async {
    await _repository.commitAction(habitId);
  }

  Future<void> undoAction({required String habitId}) async {
    await _repository.undoAction(habitId);
  }

  Future<void> purgeTutorialData(String userId) async {
    // Aquí es donde en el futuro podrías agregar validaciones extra antes de purgar
    await _repository.purgeTutorialData(userId);
  }

  Future<void> completeTutorialStep(String stepId) async {
    await _repository.completeTutorialStep(stepId);
  }
}
