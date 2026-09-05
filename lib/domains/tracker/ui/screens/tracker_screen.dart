import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/habit_card.dart';
import '../widgets/if_then_bottom_sheet.dart';
import '../widgets/epic_mission_card.dart';
import '../../providers/tracker_provider.dart';
import '../../providers/day_zero_provider.dart';
import 'habit_creation_screen.dart';
import '../../models/habit.dart';
import '../widgets/flow_timer_screen.dart';
import 'tutorial_failure_screen.dart';
import '../../../../core/providers/session_provider.dart';

class TrackerScreen extends ConsumerStatefulWidget {
  const TrackerScreen({super.key});

  @override
  ConsumerState<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends ConsumerState<TrackerScreen> {
  void _showAddHabitSheet() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const HabitCreationScreen()),
    );
  }

  void _showIfThenSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const IfThenBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Interceptamos primero el estado del Día Cero.
    //    Si hay pasos de tutorial activos, secuestramos la UI estándar.
    final dayZeroState = ref.watch(dayZeroProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,

      // 2. Manejo estricto de estados de carga — sin pantallas congeladas.
      body: dayZeroState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error al cargar el tutorial: $error',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
        data: (tutorialSteps) {
          // 3. Interceptación: tutorial activo → dashboard de Día Cero.
          if (tutorialSteps.isNotEmpty) {
            return _buildDayZeroDashboard(context, tutorialSteps);
          }

          // 4. Flujo normal: sin tutorial → panel estándar de hábitos.
          return _buildStandardDashboard(context, ref);
        },
      ),

      // Los FABs solo son relevantes en el flujo estándar.
      // Se ocultan durante el Día Cero para mantener el foco del usuario.
      floatingActionButton: dayZeroState.maybeWhen(
        data: (steps) => steps.isNotEmpty ? null : _buildFabs(context),
        orElse: () => null,
      ),
    );
  }

  /// Dashboard de Iniciación (Pasillo Lineal) — Sirve UNA sola misión épica a la vez.
  Widget _buildDayZeroDashboard(
    BuildContext context,
    List<Map<String, dynamic>> tutorialSteps,
  ) {
    // LEY DE HICK: Extraemos SOLO la primera misión de la fila.
    // Las demás están en SQLite, pero el usuario no las ve, reduciendo la carga cognitiva.
    final step = tutorialSteps.first;
    final stepId = step['id'] as String;
    final stepTitle = step['title'] as String? ?? '';

    // Variables dinámicas para el "Mentor"
    IconData missionIcon;
    String missionDescription;
    VoidCallback missionAction;

    // Evaluamos qué misión toca usando los títulos que inyectamos en el Caso de Uso
    if (stepTitle.contains('Ancla')) {
      missionIcon = Icons.anchor_rounded;
      missionDescription =
          'Tú conoces tu vida. Escribe una acción rápida (menos de 2 minutos) que harás inmediatamente después de despertar.';
      missionAction = () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HabitCreationScreen(tutorialStepIdToRemove: stepId),
          ),
        );
      };
    } else if (stepTitle.contains('Defensa')) {
      missionIcon = Icons.shield_outlined;
      missionDescription =
          'El enemigo atacará. Configura tu protocolo de contingencia conductual para proteger tu progreso en tus horas más bajas.';
      missionAction = () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => IfThenBottomSheet(tutorialStepIdToRemove: stepId),
        );
      };
    } else {
      // Tarea 3: El Fracaso
      missionIcon = Icons.warning_amber_rounded;
      missionDescription =
          'Conoce las consecuencias. En este juego, la Aversión a la Pérdida es real. Saltarte tu palabra destruirá tu barra de salud (HP).';
      missionAction = () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TutorialFailureScreen(tutorialStepId: stepId),
          ),
        );
      };
    }

    // Centramos la Tarjeta Épica en medio de la pantalla vacía
    return Center(
      child: EpicMissionCard(
        title: stepTitle,
        description: missionDescription,
        icon: missionIcon,
        onPressed: missionAction,
      ),
    );
  }

  /// Panel estándar del rastreador — hábitos diarios regulares.
  Widget _buildStandardDashboard(BuildContext context, WidgetRef ref) {
    // 1. Obtenemos el ID del usuario real
    final userIdAsync = ref.watch(localUserIdProvider);

    return userIdAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, st) => Center(child: Text('Error de sesión: $error')),
      data: (userId) {
        if (userId == null) {
          return const Center(
            child: Text(
              'No se encontró un usuario activo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        // Le pasamos el ID real al tracker
        final habitsAsyncValue = ref.watch(habitsProvider(userId));

        return habitsAsyncValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text('Error al cargar SQLite: $error')),
          data: (habits) {
            if (habits.isEmpty) {
              return const Center(
                child: Text(
                  'Tu lista está vacía.\n¡Apila tu primer hábito!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 140),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habitMap = habits[index];

                return InkWell(
                  onTap: () {
                    final habitObj = Habit.fromMap(habitMap);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => FlowTimerScreen(habit: habitObj),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: HabitCard(
                    title: habitMap['title'] ?? 'Sin título',
                    baseXp: habitMap['base_xp'] ?? 10,
                    isCompleted: (habitMap['completed_count'] ?? 0) > 0,
                    id: '${habitMap['id']}',
                    syncStatus: habitMap['current_sync_status'] as String?,
                    clientTimestamp: habitMap['log_timestamp'] as String?,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  /// FABs del panel estándar — ocultos durante el Día Cero.
  Widget _buildFabs(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton.small(
          heroTag: 'if_then_fab',
          onPressed: _showIfThenSheet,
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.primary,
          elevation: 2,
          child: const Icon(Icons.shield_outlined),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          heroTag: 'habit_fab',
          onPressed: _showAddHabitSheet,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.surface,
          elevation: 4,
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}
