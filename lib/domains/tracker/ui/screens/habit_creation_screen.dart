import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/session_provider.dart';
import '../../providers/tracker_provider.dart';
import '../widgets/trigger_section.dart';
import '../widgets/friction_section.dart';
import '../widgets/recurrence_section.dart';
import '../widgets/priority_section.dart';

class HabitCreationScreen extends ConsumerStatefulWidget {
  /// Si viene del Día Cero, contiene el ID del paso a eliminar tras guardar.
  final String? tutorialStepIdToRemove;

  const HabitCreationScreen({super.key, this.tutorialStepIdToRemove});

  @override
  ConsumerState<HabitCreationScreen> createState() =>
      _HabitCreationScreenState();
}

class _HabitCreationScreenState extends ConsumerState<HabitCreationScreen> {
  final TextEditingController _anchorController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  bool _isFlow = false;

  @override
  void dispose() {
    _anchorController.dispose();
    _timeController.dispose();
    _titleController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _toggleDay(int day, String currentPattern) {
    List<int> days = currentPattern.isNotEmpty
        ? currentPattern.split(',').map(int.parse).toList()
        : [];

    if (days.contains(day)) {
      if (days.length > 1) days.remove(day);
    } else {
      days.add(day);
      days.sort();
    }

    ref
        .read(habitDraftControllerProvider.notifier)
        .setRecurrencePattern(days.join(','));
  }

  Future<void> _saveHabit(BuildContext context) async {
    // Obtenemos el ID real (al ser un FutureProvider, usamos .value o validamos)
    final userId = ref.read(localUserIdProvider).value;

    if (userId == null) {
      // Manejar el caso de que no haya sesión
      return;
    }

    final notifier = ref.read(habitDraftControllerProvider.notifier);
    final success = await notifier.saveHabit(
      userId, // ¡Adiós al hardcoding!
      tutorialStepIdToRemove: widget.tutorialStepIdToRemove,
    );
    // ... resto de tu código ...

    if (!context.mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Faltan campos obligatorios en el gatillo o el título.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(habitDraftControllerProvider);
    final notifier = ref.read(habitDraftControllerProvider.notifier);
    final theme = Theme.of(context);

    final List<int> selectedDays = draft.recurrencePattern.isNotEmpty
        ? draft.recurrencePattern.split(',').map(int.parse).toList()
        : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forjar Hábito'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TriggerSection(
                triggerType: draft.triggerType,
                anchorController: _anchorController,
                timeController: _timeController,
                titleController: _titleController,
                onTriggerTypeChanged: (type) =>
                    notifier.toggleTriggerType(type),
                onAnchorChanged: notifier.updateAnchorEvent,
                onTimeChanged: notifier.updateTriggerTime,
                onTitleChanged: notifier.updateTitle,
              ),
              const SizedBox(height: 32),

              const Divider(),
              FrictionSection(
                isFlow: _isFlow,
                durationController: _durationController,
                onFlowToggled: (val) {
                  setState(() => _isFlow = val);
                  if (val) {
                    _durationController.text = '15';
                    notifier.updateDuration(15);
                  } else {
                    _durationController.clear();
                    notifier.updateDuration(null);
                  }
                },
                onDurationChanged: (val) =>
                    notifier.updateDuration(int.tryParse(val)),
              ),
              const SizedBox(height: 32),

              const Divider(),
              RecurrenceSection(
                selectedDays: selectedDays,
                onDayToggled: (day) => _toggleDay(day, draft.recurrencePattern),
              ),
              const SizedBox(height: 32),

              const Divider(),
              PrioritySection(
                selectedPriority: draft.priorityLevel,
                onPriorityChanged: (priority) => notifier.setPriority(priority),
              ),
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _saveHabit(context),
                  child: const Text(
                    'Forjar Hábito',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
