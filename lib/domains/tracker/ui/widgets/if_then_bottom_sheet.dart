import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/session_provider.dart'; // Tu provider de sesión real
import '../../providers/shadow_account_provider.dart'; // Mantenemos este para leer la vulnerabilidad
import '../../providers/tracker_provider.dart';
import '../../providers/day_zero_provider.dart';

class IfThenBottomSheet extends ConsumerStatefulWidget {
  final String? tutorialStepIdToRemove;

  const IfThenBottomSheet({super.key, this.tutorialStepIdToRemove});

  @override
  ConsumerState<IfThenBottomSheet> createState() => _IfThenBottomSheetState();
}

class _IfThenBottomSheetState extends ConsumerState<IfThenBottomSheet> {
  final TextEditingController _triggerController = TextEditingController();
  final TextEditingController _responseController = TextEditingController();
  final FocusNode _responseFocusNode = FocusNode();
  bool _isSaving = false;

  @override
  void dispose() {
    _triggerController.dispose();
    _responseController.dispose();
    _responseFocusNode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final trigger = _triggerController.text.trim();
    final response = _responseController.text.trim();

    if (trigger.isEmpty || response.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      // 1. Obtenemos el ID real del usuario
      final userId = ref.read(localUserIdProvider).value;
      if (userId == null) throw Exception("Sesión no encontrada");

      // 2. Guardamos la misión usando la Arquitectura Limpia
      await ref
          .read(trackerUseCasesProvider)
          .createIfThenMission(
            userId: userId,
            trigger: trigger,
            response: response,
          );

      // 3. Completamos la Tarea de Iniciación (Día Cero)
      if (widget.tutorialStepIdToRemove != null) {
        await ref
            .read(trackerUseCasesProvider)
            .completeTutorialStep(widget.tutorialStepIdToRemove!);
        ref.invalidate(dayZeroProvider);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    // Pre-llenado inteligente de la vulnerabilidad
    final userAsync = ref.watch(shadowAccountProvider);
    userAsync.whenData((user) {
      if (_triggerController.text.isEmpty &&
          user != null &&
          user['primary_vulnerability'] != null) {
        _triggerController.text =
            'Siento el impulso de ${user['primary_vulnerability']}';
      }
    });

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

          TextField(
            controller: _triggerController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Si... (Desencadenante)',
              labelStyle: const TextStyle(color: AppColors.warning),
              hintText: 'Ej. Siento el impulso de revisar redes',
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
            autofocus: widget.tutorialStepIdToRemove == null,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_responseFocusNode),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Icon(Icons.arrow_downward, color: AppColors.textSecondary),
            ),
          ),

          TextField(
            controller: _responseController,
            focusNode: _responseFocusNode,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Entonces... (Acción)',
              labelStyle: const TextStyle(color: AppColors.primary),
              hintText: 'Ej. Haré 10 flexiones de inmediato',
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
            onSubmitted: (_) => _save(),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Blindar Hábito',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
