import 'package:flutter/material.dart';

class PrioritySection extends StatelessWidget {
  final String selectedPriority;
  final ValueChanged<String> onPriorityChanged;

  const PrioritySection({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          selected: {selectedPriority},
          onSelectionChanged: (Set<String> newSelection) =>
              onPriorityChanged(newSelection.first),
        ),
      ],
    );
  }
}
