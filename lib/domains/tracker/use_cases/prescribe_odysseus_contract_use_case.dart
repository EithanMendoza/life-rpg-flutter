import 'package:uuid/uuid.dart';
// Asume las rutas de tus modelos de dominio puros
import '../models/habit.dart';
import '../models/if_then_mission.dart'; // Si no existe, deberás crear esta entidad pura
import 'clinical_templates.dart';

/// Clase contenedora para retornar el paquete completo del contrato.
class OdysseusContract {
  final List<Habit> habits;
  final List<IfThenMission> missions;

  OdysseusContract({required this.habits, required this.missions});
}

/// Use Case puro que transforma el Diagnóstico en un Sistema de Vida.
/// No tiene estado, no toca la BD ni la UI (Cumplimiento de SRP y Clean Architecture).
class PrescribeOdysseusContractUseCase {
  OdysseusContract execute({
    required String userId,
    required String archetype,
    required String vulnerability,
    required String targetSleepTime,
  }) {
    final List<Habit> generatedHabits = [];
    final List<IfThenMission> generatedMissions = [];
    final String nowUtc = DateTime.now().toUtc().toIso8601String();
    const uuid = Uuid();

    // 1. Inyectar Hábitos del Arquetipo (Fase 1: Inercia Conductual)
    final archetypeData =
        ClinicalTemplates.archetypeHabits[archetype.toLowerCase()] ?? [];
    for (var habitData in archetypeData) {
      generatedHabits.add(
        Habit(
          id: uuid.v4(),
          userId: userId,
          title: habitData['title'],
          createdAt: nowUtc,
          triggerType: habitData['triggerType'],
          anchorEvent: habitData['anchor'],
          habitType: 'standard',
          priorityLevel: 'medium',
          recurrencePattern: '1,2,3,4,5,6,7', // Diario por defecto
          isRecovery: false,
        ),
      );
    }

    // 2. Inyectar Hábito Estricto: Ritual de Apagado (Fase 4: Cierre de Ciclos)
    // Anclado a la hora de dormir proporcionada en el diagnóstico
    generatedHabits.add(
      Habit(
        id: uuid.v4(),
        userId: userId,
        title: 'Ritual de Apagado (Modo Sueño)',
        createdAt: nowUtc,
        triggerType: 'time',
        triggerTime: targetSleepTime,
        habitType: 'standard',
        priorityLevel: 'epic', // Prioridad máxima para proteger el descanso
        recurrencePattern: '1,2,3,4,5,6,7',
        isRecovery: false,
      ),
    );

    // 3. Inyectar Misiones Defensivas de la Vulnerabilidad
    final vulnerabilityData =
        ClinicalTemplates.vulnerabilityMissions[vulnerability.toLowerCase()] ??
        [];
    for (var missionData in vulnerabilityData) {
      generatedMissions.add(
        IfThenMission(
          id: uuid.v4(),
          userId: userId,
          triggerCondition: missionData['trigger']!,
          actionResponse: missionData['response']!,
          createdAt: nowUtc,
        ),
      );
    }

    // 4. Retornar el contrato completo para que un Provider/Controller lo persista
    return OdysseusContract(
      habits: generatedHabits,
      missions: generatedMissions,
    );
  }
}
