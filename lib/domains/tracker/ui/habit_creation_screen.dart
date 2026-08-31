import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../gamification/ui/widgets/projected_xp_widget.dart';
import '../providers/tracker_provider.dart';

class HabitCreationScreen extends ConsumerStatefulWidget {
  const HabitCreationScreen({super.key});

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
      if (days.length > 1) days.remove(day); // Prevenir que se quede sin días
    } else {
      days.add(day);
      days.sort();
    }

    ref
        .read(habitDraftControllerProvider.notifier)
        .setRecurrencePattern(days.join(','));
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(habitDraftControllerProvider);
    final notifier = ref.read(habitDraftControllerProvider.notifier);
    final theme = Theme.of(context);

    // Parseamos el patrón actual para el calendario
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
              // ==========================================
              // 1. SECCIÓN MAD LIBS (Gatillo Híbrido)
              // ==========================================
              Text(
                'Después de...',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),

              // Selector Evento / Hora
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'event',
                    label: Text('Un Evento'),
                    icon: Icon(Icons.flash_on),
                  ),
                  ButtonSegment(
                    value: 'time',
                    label: Text('Una Hora'),
                    icon: Icon(Icons.schedule),
                  ),
                ],
                selected: {draft.triggerType},
                onSelectionChanged: (Set<String> newSelection) {
                  notifier.toggleTriggerType(newSelection.first);
                },
                style: SegmentedButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  selectedForegroundColor: theme.colorScheme.onPrimary,
                  selectedBackgroundColor: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Input Dinámico del Gatillo
              if (draft.triggerType == 'event')
                TextField(
                  controller: _anchorController,
                  onChanged: notifier.updateAnchorEvent,
                  decoration: const InputDecoration(
                    hintText: 'Ej. Terminar mi ronda de vigilancia',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                )
              else
                TextField(
                  controller: _timeController,
                  onChanged: notifier.updateTriggerTime,
                  decoration: const InputDecoration(
                    hintText: 'Ej. 07:00 AM',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                ),

              const SizedBox(height: 24),
              Text(
                'voy a...',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _titleController,
                onChanged: notifier.updateTitle,
                decoration: const InputDecoration(
                  hintText: "Ej. Leer Can't Hurt Me",
                  border: OutlineInputBorder(),
                  filled: true,
                ),
              ),

              const SizedBox(height: 32),

              // ==========================================
              // 2. SELECTOR DE FRICCIÓN (Atómico vs Flujo)
              // ==========================================
              const Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sesión de Flujo (Timeboxing)'),
                subtitle: const Text(
                  'Requiere tiempo prolongado. Oculto = Acción Atómica.',
                ),
                value: _isFlow,
                activeColor: theme.colorScheme.primary,
                onChanged: (val) {
                  setState(() => _isFlow = val);
                  if (val) {
                    _durationController.text = '15';
                    notifier.updateDuration(15);
                  } else {
                    _durationController.clear();
                    notifier.updateDuration(null);
                  }
                },
              ),

              if (_isFlow) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        onChanged: (val) =>
                            notifier.updateDuration(int.tryParse(val)),
                        decoration: const InputDecoration(
                          labelText: 'Duración (Minutos)',
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // ==========================================
                    // INYECCIÓN ADR-004: Widget de Gamificación
                    // ==========================================
                    const ProjectedXpWidget(),
                  ],
                ),
              ],

              const SizedBox(height: 32),

              // ==========================================
              // 3. CALENDARIO DINÁMICO
              // ==========================================
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Recurrencia',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _dayLabels.entries.map((entry) {
                  final isSelected = selectedDays.contains(entry.key);
                  return GestureDetector(
                    onTap: () => _toggleDay(entry.key, draft.recurrencePattern),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceVariant,
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // ==========================================
              // 4. SELECTOR DE DAÑO (Prioridad)
              // ==========================================
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Nivel de Impacto',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'low', label: Text('Bajo')),
                  ButtonSegment(value: 'medium', label: Text('Medio')),
                  ButtonSegment(value: 'epic', label: Text('Épico')),
                ],
                selected: {draft.priorityLevel},
                onSelectionChanged: (Set<String> newSelection) {
                  notifier.setPriority(newSelection.first);
                },
              ),

              const SizedBox(height: 48),

              // ==========================================
              // 5. BOTÓN DE GUARDADO
              // ==========================================
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
                  onPressed: () async {
                    // Se asume la cuenta de sombra temporal
                    final success = await notifier.saveHabit(
                      'shadow-account-id',
                    );
                    if (success && context.mounted) {
                      Navigator.of(context).pop();
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Faltan campos obligatorios en el gatillo o el título.',
                          ),
                        ),
                      );
                    }
                  },
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
