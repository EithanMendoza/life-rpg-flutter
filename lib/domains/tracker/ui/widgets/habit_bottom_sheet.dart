import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/tracker_provider.dart';

class HabitBottomSheet extends ConsumerStatefulWidget {
  const HabitBottomSheet({super.key});

  @override
  ConsumerState<HabitBottomSheet> createState() => _HabitBottomSheetState();
}

class _HabitBottomSheetState extends ConsumerState<HabitBottomSheet> {
  final TextEditingController _anchorController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  // Estado local del formulario
  final List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7]; // Lunes a Domingo
  bool _isRecovery = false;

  final Map<int, String> _dayLabels = {
    1: 'L',
    2: 'M',
    3: 'M',
    4: 'J',
    5: 'V',
    6: 'S',
    7: 'D',
  };

  @override
  void dispose() {
    _anchorController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        if (_selectedDays.length > 1)
          _selectedDays.remove(day); // Obliga mínimo 1 día
      } else {
        _selectedDays.add(day);
        _selectedDays.sort();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: 16 + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Apilar Nuevo Hábito',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),

          // 1. Formato Guiado (Evento Ancla)
          const Text(
            'Después de...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _anchorController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Ej. Terminar mi ronda nocturna',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 1. Formato Guiado (Acción)
          const Text(
            'Voy a...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: "Ej. Leer Can't Hurt Me (10 min)",
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 2. Selector Visual de Frecuencia
          const Text(
            'Frecuencia',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _dayLabels.entries.map((entry) {
              final isSelected = _selectedDays.contains(entry.key);
              return GestureDetector(
                onTap: () => _toggleDay(entry.key),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: isSelected
                      ? AppColors.primary
                      : AppColors.background,
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.surface
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // 3. Switch de Modo Recuperación
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Modo Recuperación',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Hábito de baja fricción para días pesados.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            secondary: Icon(
              Icons.spa_outlined,
              color: _isRecovery ? Colors.tealAccent : AppColors.textSecondary,
            ),
            activeColor: Colors.tealAccent,
            value: _isRecovery,
            onChanged: (val) => setState(() => _isRecovery = val),
          ),

          const SizedBox(height: 24),

          // 4. Botón de Guardado (Fricción Cero)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final pattern = _selectedDays.join(',');

                // Disparamos la mutación en el estado
                ref
                    .read(trackerControllerProvider.notifier)
                    .createNewHabit(
                      userId: 'shadow-account-id', // TODO: ID temporal
                      title: _titleController.text,
                      anchorEvent: _anchorController.text,
                      recurrencePattern: pattern,
                      isRecovery: _isRecovery,
                    );

                // Cerramos el BottomSheet
                Navigator.of(context).pop();
              },
              child: const Text(
                'Guardar Hábito',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
