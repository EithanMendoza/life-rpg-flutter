import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Importa Riverpod
// Importamos nuestro sistema de diseño centralizado
import '../../../../core/theme/app_colors.dart';
// Importa tu provider del tracker (ajusta la ruta según tu estructura de carpetas)
import '../../providers/tracker_provider.dart';

class HabitBottomSheet extends ConsumerStatefulWidget {
  // 2. Cambiado a ConsumerStatefulWidget
  const HabitBottomSheet({super.key});

  @override
  ConsumerState<HabitBottomSheet> createState() => _HabitBottomSheetState();
}

class _HabitBottomSheetState extends ConsumerState<HabitBottomSheet> {
  // 3. Cambiado a ConsumerState
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos el espacio que ocupa el teclado en la pantalla
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      // Utilizamos el color de superficie para diferenciar el BottomSheet del fondo principal
      color: AppColors.surface,
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 24.0,
        // ADVERTENCIA PM RESUELTA: Sumamos el bottomInset al padding base
        // para que el formulario siempre flote sobre el teclado.
        bottom: 16.0 + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Vital para no ocupar toda la pantalla
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nuevo Hábito',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: AppColors.textPrimary),
            // Aseguramos que el contraste visual guíe al usuario
            decoration: InputDecoration(
              hintText: 'Ej. 15 min de Duolingo',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.background,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.textSecondary.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52, // Altura táctil recomendada por Material Design
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                elevation: 0, // ADR-001: Fricción cero visualmente
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final titleText = _titleController.text.trim();
                if (titleText.isNotEmpty) {
                  // 4. Ejecutamos la inserción local en SQLite mediante el controlador de Riverpod
                  // (Usamos un ID de usuario temporal o el real de tu sesión actual)
                  ref
                      .read(trackerControllerProvider.notifier)
                      .createNewHabit('local_user', titleText);

                  // 5. Cerramos el modal de inmediato (Fricción Cero / Offline-First)
                  Navigator.of(context).pop();
                }
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
