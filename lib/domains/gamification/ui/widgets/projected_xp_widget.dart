import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importamos el estado del tracker (Lectura pasiva, sin romper aislamiento hacia arriba)
// Ajusta la ruta dependiendo de cómo nombraste tu archivo unificado de providers
import '../../../tracker/providers/tracker_provider.dart';

class ProjectedXpWidget extends ConsumerWidget {
  const ProjectedXpWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Escuchamos el borrador del tracker en tiempo real
    final draft = ref.watch(habitDraftControllerProvider);

    // 2. Lógica de Gamificación pura (Aislada del tracker)
    // Si no han escrito duración, calculamos basados en 15 minutos por defecto.
    final int baseMinutes = draft.durationMinutes ?? 15;

    double multiplier;
    switch (draft.priorityLevel) {
      case 'low':
        multiplier = 0.5; // Tareas triviales dan menos XP
        break;
      case 'epic':
        multiplier = 2.0; // Tareas de alto impacto duplican XP
        break;
      case 'medium':
      default:
        multiplier = 1.0;
        break;
    }

    // 3. Fórmula Final
    final projectedXp = (baseMinutes * multiplier).round();

    final theme = Theme.of(context);

    // 4. Renderizado Visual Reactivo
    return Container(
      height: 56,
      width: 80,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.6)),
      ),
      child: Center(
        child: Text(
          '+$projectedXp XP',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
