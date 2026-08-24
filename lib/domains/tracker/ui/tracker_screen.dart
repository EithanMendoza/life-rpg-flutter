import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tracker_provider.dart'; // Ajusta la ruta si tu archivo de providers está en otra carpeta
import 'widgets/habit_card.dart';
import 'widgets/habit_bottom_sheet.dart';
import 'widgets/if_then_bottom_sheet.dart';

class TrackerScreen extends ConsumerStatefulWidget {
  const TrackerScreen({super.key});

  @override
  ConsumerState<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends ConsumerState<TrackerScreen> {
  void _showAddHabitSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const HabitBottomSheet(),
    );
  }

  // Método para invocar el BottomSheet de If-Then
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
    // Observamos el provider de hábitos para reactividad automática en tiempo real
    const currentUserId = 'local_user';
    final habitsAsync = ref.watch(habitsProvider(currentUserId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return const Center(
              child: Text(
                'No hay hábitos aún. ¡Crea el primero con el botón +!',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 140),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];

              // 🛡️ Casteo seguro para evitar errores de tipo si SQLite devuelve null o num
              final int completedCount =
                  (habit['completed_count'] as num?)?.toInt() ?? 0;
              final bool isCompleted = completedCount > 0;

              return HabitCard(
                id: habit['id'] as String,
                title: habit['title'] as String,
                baseXp: habit['base_xp'] as int,
                isCompleted:
                    isCompleted, // <-- Aquí pasamos el estado real de SQLite
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            'Error al cargar hábitos: $err',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),

      // Reestructuramos el área de acción con una columna de FABs
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Botón secundario (Misiones If-Then)
          FloatingActionButton.small(
            heroTag: 'if_then_fab', // Evita conflictos de animación en Flutter
            onPressed: _showIfThenSheet,
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.primary,
            elevation: 2,
            child: const Icon(Icons.shield_outlined),
          ),
          const SizedBox(height: 16),
          // Botón principal (Nuevos Hábitos)
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
