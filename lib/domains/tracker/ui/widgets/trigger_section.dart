import 'package:flutter/material.dart';

class TriggerSection extends StatelessWidget {
  final String triggerType;
  final TextEditingController anchorController;
  final TextEditingController timeController;
  final TextEditingController titleController;
  final ValueChanged<String> onTriggerTypeChanged;
  final ValueChanged<String> onAnchorChanged;
  final ValueChanged<String> onTimeChanged;
  final ValueChanged<String> onTitleChanged;

  const TriggerSection({
    super.key,
    required this.triggerType,
    required this.anchorController,
    required this.timeController,
    required this.titleController,
    required this.onTriggerTypeChanged,
    required this.onAnchorChanged,
    required this.onTimeChanged,
    required this.onTitleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Después de...',
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 12),
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
          selected: {triggerType},
          onSelectionChanged: (Set<String> newSelection) =>
              onTriggerTypeChanged(newSelection.first),
          style: SegmentedButton.styleFrom(
            backgroundColor: theme.colorScheme.surface,
            selectedForegroundColor: theme.colorScheme.onPrimary,
            selectedBackgroundColor: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        if (triggerType == 'event')
          TextField(
            controller: anchorController,
            onChanged: onAnchorChanged,
            decoration: const InputDecoration(
              hintText: 'Ej. Terminar mi ronda de vigilancia',
              border: OutlineInputBorder(),
              filled: true,
            ),
          )
        else
          TextField(
            controller: timeController,
            onChanged: onTimeChanged,
            decoration: const InputDecoration(
              hintText: 'Ej. 07:00 AM',
              border: OutlineInputBorder(),
              filled: true,
            ),
          ),
        const SizedBox(height: 24),
        Text(
          'voy a...',
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: titleController,
          onChanged: onTitleChanged,
          decoration: const InputDecoration(
            hintText: "Ej. Leer Can't Hurt Me",
            border: OutlineInputBorder(),
            filled: true,
          ),
        ),
      ],
    );
  }
}
