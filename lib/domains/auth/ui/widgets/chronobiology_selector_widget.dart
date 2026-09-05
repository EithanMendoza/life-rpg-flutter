import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_draft_provider.dart';

class ChronobiologySelectorWidget extends ConsumerStatefulWidget {
  final VoidCallback
  onSelected; // Cambiamos a VoidCallback porque el provider se actualiza aquí adentro

  const ChronobiologySelectorWidget({super.key, required this.onSelected});

  @override
  ConsumerState<ChronobiologySelectorWidget> createState() =>
      _ChronobiologySelectorWidgetState();
}

class _ChronobiologySelectorWidgetState
    extends ConsumerState<ChronobiologySelectorWidget> {
  TimeOfDay? _wakeTime;
  TimeOfDay? _sleepTime;

  Future<void> _pickTime(bool isWakeTime) async {
    final initialTime = isWakeTime
        ? const TimeOfDay(hour: 6, minute: 0)
        : const TimeOfDay(hour: 22, minute: 30);

    final picked = await showTimePicker(
      context: context,
      initialTime: (isWakeTime ? _wakeTime : _sleepTime) ?? initialTime,
      builder: (context, child) {
        // Forzamos el tema oscuro para mantener la inmersión
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isWakeTime) {
          _wakeTime = picked;
        } else {
          _sleepTime = picked;
        }
      });
    }
  }

  void _submitTimes() {
    if (_wakeTime == null || _sleepTime == null) return;

    final controller = ref.read(authDraftProvider.notifier);
    controller.setDayStartTime(_wakeTime!);
    controller.setTargetSleepTime(_sleepTime!);

    // Lanzamos la evaluación matemática
    if (controller.isSleepDeprived()) {
      _showAmberAlert();
    } else {
      widget.onSelected();
    }
  }

  void _showAmberAlert() {
    showDialog(
      context: context,
      barrierDismissible: false, // Obliga al usuario a interactuar con el botón
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.amber.shade700, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.amber.shade700,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Modo Supervivencia',
                style: TextStyle(
                  color: Colors.amber.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Tienes menos de 6 horas para dormir. La ciencia indica que hoy te costará más mantener la disciplina.\n\nTe daremos misiones más cortas, pero no aceptaremos excusas.',
          style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.amber.shade700),
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el modal
              widget.onSelected(); // Avanza al siguiente paso
            },
            child: const Text(
              'ASUMIR CONSECUENCIAS',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isReady = _wakeTime != null && _sleepTime != null;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'El Reloj Biológico',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),

        _buildTimeCard(
          context: context,
          title: '¿A qué hora arranca tu día?',
          icon: Icons.wb_sunny_outlined,
          selectedTime: _wakeTime,
          onTap: () => _pickTime(true),
        ),

        const SizedBox(height: 24),

        _buildTimeCard(
          context: context,
          title: '¿A qué hora debes desconectarte?',
          icon: Icons.nights_stay_outlined,
          selectedTime: _sleepTime,
          onTap: () => _pickTime(false),
        ),

        const Spacer(),

        // Botón condicional: Solo aparece cuando ambas horas están seleccionadas
        AnimatedOpacity(
          opacity: isReady ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isReady ? _submitTimes : null,
              child: const Text(
                'Continuar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTimeCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required TimeOfDay? selectedTime,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(
            color: selectedTime != null
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.2),
            width: selectedTime != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              selectedTime != null ? selectedTime.format(context) : '-- : --',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: selectedTime != null
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
