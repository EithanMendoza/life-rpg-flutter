import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Importamos Riverpod
import '../widgets/habit_card.dart';
import '../widgets/if_then_bottom_sheet.dart';
import '../../providers/tracker_provider.dart';
import 'habit_creation_screen.dart';
import '../../models/habit.dart'; // Para convertir el Map en Objeto
import '../widgets/flow_timer_screen.dart'; // La nueva pantalla del cronómetro

// 2. Cambiamos StatefulWidget por ConsumerStatefulWidget
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
    // 3. Magia Reactiva: Escuchamos la base de datos a través de Riverpod
    final habitsAsyncValue = ref.watch(habitsProvider('shadow-account-id'));

    return Scaffold(
      backgroundColor: Colors.transparent,

      // 4. Manejamos los 3 estados posibles de una consulta asíncrona (Cargando, Error, Datos)
      body: habitsAsyncValue.when(
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
      ),

      floatingActionButton: Column(
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
      ),
    );
  }
}
