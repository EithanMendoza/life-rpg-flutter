import 'package:flutter/material.dart';

class ArchetypeSelectorWidget extends StatelessWidget {
  final Function(String) onSelected;

  const ArchetypeSelectorWidget({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '¿Qué quieres cambiar primero?',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),

        _buildIdentityCard(
          context: context,
          id: 'vital',
          title: 'El Vital',
          subtitle: 'Quiero mejorar mi salud, energía y descanso.',
          icon: Icons.favorite_border,
        ),
        _buildIdentityCard(
          context: context,
          id: 'scholar',
          title: 'El Erudito',
          subtitle: 'Quiero estudiar, leer más y dejar las pantallas.',
          icon: Icons.menu_book,
        ),
        _buildIdentityCard(
          context: context,
          id: 'architect',
          title: 'El Arquitecto',
          subtitle: 'Quiero organizar mis proyectos y mi dinero.',
          icon: Icons.architecture,
        ),
        _buildIdentityCard(
          context: context,
          id: 'explorer',
          title: 'El Explorador',
          subtitle: 'Quiero empezar desde cero, a mi ritmo.',
          icon: Icons.explore_outlined,
        ),
      ],
    );
  }

  Widget _buildIdentityCard({
    required BuildContext context,
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () => onSelected(id), // Avanza automáticamente al tocar
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, size: 32, color: theme.colorScheme.primary),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
