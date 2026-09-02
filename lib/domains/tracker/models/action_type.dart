class ActionType {
  static const String habitCompleted = 'habit_completed';
  static const String ifThenSurvived = 'if_then_survived';
  static const String hpLost = 'hp_lost';

  // Nuevos estados (Contrato Clínico)
  static const String deepWorkFailed = 'deep_work_failed';
  static const String panicButtonSurvived = 'panic_button_survived';

  static bool isValid(String type) {
    if (type.startsWith('$habitCompleted:')) return true;

    const validTypes = [
      habitCompleted,
      ifThenSurvived,
      hpLost,
      deepWorkFailed,
      panicButtonSurvived,
    ];
    return validTypes.contains(type);
  }
}
