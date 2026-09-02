import 'package:flutter/material.dart';
import '../../../gamification/ui/widgets/projected_xp_widget.dart';

class FrictionSection extends StatelessWidget {
  final bool isFlow;
  final TextEditingController durationController;
  final ValueChanged<bool> onFlowToggled;
  final ValueChanged<String> onDurationChanged;

  const FrictionSection({
    super.key,
    required this.isFlow,
    required this.durationController,
    required this.onFlowToggled,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Sesión de Flujo (Timeboxing)'),
          subtitle: const Text(
            'Requiere tiempo prolongado. Oculto = Acción Atómica.',
          ),
          value: isFlow,
          activeColor: theme.colorScheme.primary,
          onChanged: onFlowToggled,
        ),
        if (isFlow) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  onChanged: onDurationChanged,
                  decoration: const InputDecoration(
                    labelText: 'Duración (Minutos)',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const ProjectedXpWidget(),
            ],
          ),
        ],
      ],
    );
  }
}
