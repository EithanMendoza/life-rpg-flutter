import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ArchetypeSelectorWidget extends StatelessWidget {
  final Function(String) onSelected;

  const ArchetypeSelectorWidget({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Pilar de Identidad',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '¿Qué arquetipo define tu objetivo actual?',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 48),
        _buildOption(
          'Guerrero',
          'Fuerza y Resistencia',
          Icons.fitness_center,
          context,
        ),
        _buildOption(
          'Erudito',
          'Conocimiento y Enfoque',
          Icons.menu_book,
          context,
        ),
        _buildOption('Alquimista', 'Creación y Código', Icons.code, context),
      ],
    );
  }

  Widget _buildOption(
    String id,
    String desc,
    IconData icon,
    BuildContext context,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.surface,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          id,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          desc,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        onTap: () => onSelected(id.toLowerCase()),
      ),
    );
  }
}
