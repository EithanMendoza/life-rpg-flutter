import 'package:flutter/material.dart';
// Importación exclusiva del sistema transversal (Core). ADR-002 respetado.
import '../../../../core/theme/app_colors.dart';

class IfThenBottomSheet extends StatefulWidget {
  const IfThenBottomSheet({super.key});

  @override
  State<IfThenBottomSheet> createState() => _IfThenBottomSheetState();
}

class _IfThenBottomSheetState extends State<IfThenBottomSheet> {
  final TextEditingController _triggerController = TextEditingController();
  final TextEditingController _responseController = TextEditingController();
  final FocusNode _responseFocusNode = FocusNode();

  @override
  void dispose() {
    _triggerController.dispose();
    _responseController.dispose();
    _responseFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos el tamaño del teclado para desplazar el BottomSheet
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 24.0,
        bottom: 16.0 + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nueva Misión If-Then',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Diseña tu plan de contingencia conductual.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          // 1. Desencadenante (If) - Se asocia con un estado de alerta o advertencia
          TextField(
            controller: _triggerController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Si... (Desencadenante)',
              labelStyle: const TextStyle(color: AppColors.warning),
              hintText: 'Ej. Siento el impulso de revisar redes',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.background,
              prefixIcon: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.textSecondary.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: AppColors.warning,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            autofocus: true,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) {
              // Transición fluida del foco sin requerir toques en la pantalla
              FocusScope.of(context).requestFocus(_responseFocusNode);
            },
          ),

          // Conector Visual (Ergonomía UI)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Icon(Icons.arrow_downward, color: AppColors.textSecondary),
            ),
          ),

          // 2. Respuesta (Then) - Se asocia con la resolución y el éxito
          TextField(
            controller: _responseController,
            focusNode: _responseFocusNode,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Entonces... (Acción)',
              labelStyle: const TextStyle(color: AppColors.primary),
              hintText: 'Ej. Haré 10 flexiones de inmediato',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.background,
              prefixIcon: const Icon(
                Icons.shield_outlined,
                color: AppColors.primary,
              ),
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
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              // Fricción cero: Permitimos guardar presionando Enter (Done) en el teclado
              Navigator.of(context).pop();
            },
          ),

          const SizedBox(height: 32),

          // 3. Botón de Acción Principal (Resolución Offline-First)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                elevation: 0, // ADR-001: Sin sombras de procesamiento o red
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // TODO: Fase 2 - Inserción WAL en tabla if_then_missions
                Navigator.of(context).pop();
              },
              child: const Text(
                'Blindar Hábito',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
