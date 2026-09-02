import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ChronobiologySelectorWidget extends StatelessWidget {
  final Function(String) onSelected;

  const ChronobiologySelectorWidget({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    // Para simplificar el MVP, usamos un selector de opciones predefinidas.
    // Luego puedes cambiarlo por un TimePicker real de Flutter.
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Pilar Cronobiológico',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '¿A qué hora debes estar desconectado?',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 48),
        _buildOption('22:00', '10:00 PM', context),
        _buildOption('23:00', '11:00 PM (Recomendado)', context),
        _buildOption('00:00', '12:00 AM (Medianoche)', context),
      ],
    );
  }

  Widget _buildOption(String time, String label, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.surface,
      child: ListTile(
        leading: const Icon(Icons.nights_stay, color: AppColors.primary),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        onTap: () => onSelected(time),
      ),
    );
  }
}
