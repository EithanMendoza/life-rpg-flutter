class ActionType {
  static const String habitCompleted = 'habit_completed';
  static const String ifThenSurvived = 'if_then_survived';
  static const String hpLost = 'hp_lost';
  static const String deepWorkFailed = 'deep_work_failed';
  static const String panicButtonSurvived = 'panic_button_survived';

  // NUEVO: Estado efímero para el simulacro del "Día Cero"
  static const String tutorialHpLoss = 'tutorial_hp_loss';

  static bool isValid(String type) {
    if (type.startsWith('$habitCompleted:')) return true;

    const validTypes = [
      habitCompleted,
      ifThenSurvived,
      hpLost,
      deepWorkFailed,
      panicButtonSurvived,
      tutorialHpLoss,
    ];
    return validTypes.contains(type);
  }
}
