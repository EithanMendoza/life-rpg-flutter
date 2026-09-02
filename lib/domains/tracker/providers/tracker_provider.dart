import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../repositories/tracker_local_repository.dart';
import '../use_cases/tracker_use_cases.dart';
import '../models/habit_draft_state.dart';

final trackerLocalRepositoryProvider = Provider<TrackerLocalRepository>((ref) {
  return const TrackerLocalRepository();
});

final trackerUseCasesProvider = Provider<TrackerUseCases>((ref) {
  final repository = ref.watch(trackerLocalRepositoryProvider);
  return TrackerUseCases(repository);
});

final habitsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, userId) async {
  final repository = ref.read(trackerLocalRepositoryProvider);
  return repository.getDailyHabits(userId);
});

final trackerControllerProvider = AsyncNotifierProvider<TrackerController, void>(() {
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
      await ref.read(trackerUseCasesProvider).createNewHabit(
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
      await ref.read(trackerUseCasesProvider).logAction(
        userId: userId,
        actionType: actionType,
        timezoneOffset: timezoneOffset,
      );
    });
  }

  Future<void> commitAction({required String habitId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(trackerLocalRepositoryProvider);
      await repository.commitAction(habitId);
    });
  }

  Future<void> undoAction({required String habitId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(trackerLocalRepositoryProvider);
      await repository.undoAction(habitId);
    });
  }
}

final habitDraftControllerProvider = StateNotifierProvider.autoDispose<HabitDraftController, HabitDraftState>((ref) {
  return HabitDraftController(ref);
});

class HabitDraftController extends StateNotifier<HabitDraftState> {
  final Ref ref;

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
    if (state.title.trim().isEmpty) return false;
    if (state.triggerType == 'event' && (state.anchorEvent == null || state.anchorEvent!.trim().isEmpty)) return false;
    if (state.triggerType == 'time' && (state.triggerTime == null || state.triggerTime!.trim().isEmpty)) return false;

    try {
      await ref.read(trackerUseCasesProvider).createNewHabit(
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
      ref.invalidate(habitsProvider(userId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> commitAction({required String habitId}) async {
    try {
      final repository = ref.read(trackerLocalRepositoryProvider);
      await repository.commitAction(habitId);
    } catch (e) {
      // Ignore
    }
  }

  Future<void> undoAction({required String habitId}) async {
    try {
      final repository = ref.read(trackerLocalRepositoryProvider);
      await repository.undoAction(habitId);
    } catch (e) {
      // Ignore
    }
  }
}
