import 'package:flutter/material.dart';

class RecurrenceSection extends StatelessWidget {
  final List<int> selectedDays;
  final ValueChanged<int> onDayToggled;

  static const Map<int, String> _dayLabels = {
    1: 'L',
    2: 'M',
    3: 'M',
    4: 'J',
    5: 'V',
    6: 'S',
    7: 'D',
  };

  const RecurrenceSection({
    super.key,
    required this.selectedDays,
    required this.onDayToggled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              onTap: () => onDayToggled(entry.key),
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
      ],
    );
  }
}
