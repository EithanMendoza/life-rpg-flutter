class Habit {
  final String id;
  final String userId;
  final String title;
  final int baseXp;
  final bool isActive;
  final String createdAt;

  // Metadatos (Fase 1.5)
  final String habitType;
  final String? anchorEvent;
  final String recurrencePattern;
  final bool isRecovery;

  // Nuevos Metadatos: Gatillos Híbridos y Prioridad (Fase de Creación)
  final String triggerType;
  final String? triggerTime;
  final int? durationMinutes;
  final String priorityLevel;

  const Habit({
    required this.id,
    required this.userId,
    required this.title,
    this.baseXp = 10,
    this.isActive = true,
    required this.createdAt,
    this.habitType = 'standard',
    this.anchorEvent,
    this.recurrencePattern = '1,2,3,4,5,6,7',
    this.isRecovery = false,
    this.triggerType = 'event',
    this.triggerTime,
    this.durationMinutes,
    this.priorityLevel = 'medium',
  });

  Habit copyWith({
    String? id,
    String? userId,
    String? title,
    int? baseXp,
    bool? isActive,
    String? createdAt,
    String? habitType,
    String? anchorEvent,
    String? recurrencePattern,
    bool? isRecovery,
    String? triggerType,
    String? triggerTime,
    int? durationMinutes,
    String? priorityLevel,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      baseXp: baseXp ?? this.baseXp,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      habitType: habitType ?? this.habitType,
      anchorEvent: anchorEvent ?? this.anchorEvent,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      isRecovery: isRecovery ?? this.isRecovery,
      triggerType: triggerType ?? this.triggerType,
      triggerTime: triggerTime ?? this.triggerTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      priorityLevel: priorityLevel ?? this.priorityLevel,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'base_xp': baseXp,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
      'habit_type': habitType,
      'anchor_event': anchorEvent,
      'recurrence_pattern': recurrencePattern,
      'is_recovery': isRecovery ? 1 : 0,
      'trigger_type': triggerType,
      'trigger_time': triggerTime,
      'duration_minutes': durationMinutes,
      'priority_level': priorityLevel,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      baseXp: map['base_xp'] as int,
      isActive: (map['is_active'] as int) == 1,
      createdAt: map['created_at'] as String,
      habitType: map['habit_type'] as String? ?? 'standard',
      anchorEvent: map['anchor_event'] as String?,
      recurrencePattern:
          map['recurrence_pattern'] as String? ?? '1,2,3,4,5,6,7',
      isRecovery: (map['is_recovery'] as int?) == 1,
      triggerType: map['trigger_type'] as String? ?? 'event',
      triggerTime: map['trigger_time'] as String?,
      durationMinutes: map['duration_minutes'] as int?,
      priorityLevel: map['priority_level'] as String? ?? 'medium',
    );
  }
}
