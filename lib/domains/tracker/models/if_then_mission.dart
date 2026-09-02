/// Entidad pura de dominio para el Modelo Conductual de Gollwitzer.
/// Representa una contingencia planificada para combatir ataques de impulsividad.
class IfThenMission {
  final String id;
  final String userId;
  final String triggerCondition;
  final String actionResponse;
  final String createdAt;

  const IfThenMission({
    required this.id,
    required this.userId,
    required this.triggerCondition,
    required this.actionResponse,
    required this.createdAt,
  });

  IfThenMission copyWith({
    String? id,
    String? userId,
    String? triggerCondition,
    String? actionResponse,
    String? createdAt,
  }) {
    return IfThenMission(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      triggerCondition: triggerCondition ?? this.triggerCondition,
      actionResponse: actionResponse ?? this.actionResponse,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'trigger_condition': triggerCondition,
      'action_response': actionResponse,
      'created_at': createdAt,
    };
  }

  factory IfThenMission.fromMap(Map<String, dynamic> map) {
    return IfThenMission(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      triggerCondition: map['trigger_condition'] as String,
      actionResponse: map['action_response'] as String,
      createdAt: map['created_at'] as String,
    );
  }
}
