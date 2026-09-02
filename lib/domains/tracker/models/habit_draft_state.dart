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
