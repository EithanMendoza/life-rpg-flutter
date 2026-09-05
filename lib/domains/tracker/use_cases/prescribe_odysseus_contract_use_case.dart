import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../models/if_then_mission.dart';

/// Clase contenedora para retornar el paquete completo del contrato.
class OdysseusContract {
  final List<Habit> habits;
  final List<IfThenMission> missions;

  OdysseusContract({required this.habits, required this.missions});
}

/// Use Case: Transformado en el Motor del Día Cero.
/// En lugar de imponer hábitos, inyecta la Lista de Iniciación.
class PrescribeOdysseusContractUseCase {
  OdysseusContract execute({
    required String userId,
    required String archetype, // Se guarda para analíticas o fases futuras
    required String vulnerability,
    required String targetSleepTime,
  }) {
    final List<Habit> generatedHabits = [];
    final String nowUtc = DateTime.now().toUtc().toIso8601String();
    const uuid = Uuid();

    // 1. TAREA DE INICIACIÓN: Forjar el Ancla
    // El título debe coincidir con el enrutador en TrackerScreen ("Ancla")
    generatedHabits.add(
      Habit(
        id: uuid.v4(),
        userId: userId,
        title: 'Tarea 1: Forja tu Primera Ancla',
        createdAt: nowUtc,
        habitType:
            'tutorial_step', // CLAVE: Esto le dice a la app que es efímero
        triggerType: 'event',
        priorityLevel: 'epic',
        recurrencePattern: '1,2,3,4,5,6,7',
        isRecovery: false,
      ),
    );

    // 2. TAREA DE INICIACIÓN: La Defensa
    // El título debe coincidir con el enrutador en TrackerScreen ("Defensa")
    generatedHabits.add(
      Habit(
        id: uuid.v4(),
        userId: userId,
        title: 'Tarea 2: Prepara tu Defensa',
        createdAt: nowUtc,
        habitType: 'tutorial_step',
        triggerType: 'event',
        priorityLevel: 'epic',
        recurrencePattern: '1,2,3,4,5,6,7',
        isRecovery: false,
      ),
    );

    // 3. TAREA DE INICIACIÓN: Gamificación y Pérdida
    // El título debe coincidir con el enrutador en TrackerScreen ("Fracaso")
    generatedHabits.add(
      Habit(
        id: uuid.v4(),
        userId: userId,
        title: 'Tarea 3: El Precio del Fracaso',
        createdAt: nowUtc,
        habitType: 'tutorial_step',
        triggerType: 'event',
        priorityLevel: 'epic',
        recurrencePattern: '1,2,3,4,5,6,7',
        isRecovery: false,
      ),
    );

    // Retornamos el contrato.
    // La lista de misiones If-Then va VACÍA porque el usuario la creará
    // manualmente al completar la Tarea 2, logrando el "Active Learning".
    return OdysseusContract(habits: generatedHabits, missions: []);
  }
}
