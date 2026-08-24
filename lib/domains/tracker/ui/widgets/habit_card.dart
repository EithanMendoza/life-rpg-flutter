import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Importa Riverpod
import '../../../../core/theme/app_colors.dart';
import '../../providers/tracker_provider.dart'; // Importa tu provider

class HabitCard extends ConsumerWidget {
  // 2. Cambiado a ConsumerWidget
  final String id; // Nuevo: ID único del hábito para referencia
  final String title;
  final int baseXp;
  final bool isCompleted;

  const HabitCard({
    super.key,
    required this.id,
    required this.title,
    required this.baseXp,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 3. Añadimos WidgetRef ref
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        // Si está completado, añadimos un borde sutil color éxito
        border: isCompleted
            ? Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.5)
            : Border.all(color: Colors.transparent, width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        // Elemento interactivo visual (Simulación de Checkbox)
        leading: InkWell(
          onTap: () async {
            if (isCompleted) return;

            final int timezoneOffset = DateTime.now().timeZoneOffset.inMinutes;

            await ref
                .read(trackerControllerProvider.notifier)
                .registerAction(
                  userId: 'local_user',
                  actionType: 'habit_completed:$id',
                  timezoneOffset: timezoneOffset,
                );

            ref.invalidate(habitsProvider('local_user'));
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  width: 2,
                ),
                color: isCompleted
                    ? AppColors.primary.withOpacity(0.2)
                    : Colors.transparent,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 18, color: AppColors.primary)
                  : null,
            ),
          ),
        ),

        // Título del Hábito
        title: Text(
          title,
          style: TextStyle(
            color: isCompleted
                ? AppColors.textSecondary
                : AppColors.textPrimary,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
          ),
        ),

        // Insignia de Recompensa (XP)
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '+$baseXp XP',
            style: TextStyle(
              color: isCompleted ? AppColors.primary : AppColors.warning,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
