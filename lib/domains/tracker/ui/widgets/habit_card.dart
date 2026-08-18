import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HabitCard extends StatelessWidget {
  final String title;
  final int baseXp;
  final bool isCompleted;

  const HabitCard({
    super.key,
    required this.title,
    required this.baseXp,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
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
          onTap: () {
            // TODO: Aquí emitiremos el evento al CoreTrackerProvider (Riverpod)
          },
          borderRadius: BorderRadius.circular(24),
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
              // Usamos el warning (naranja) si no está completado para llamar la atención
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
