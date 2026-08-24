import 'package:flutter/material.dart';
// Importamos ÚNICAMENTE recursos globales (Core).
// ADR-002: Cero dependencias de lib/domains/tracker/
import '../../../../core/theme/app_colors.dart';

class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Variables de prueba (Mock Data) para visualizar la UI
    const int mockXp = 950;
    const int mockNextLevelXp = 1600; // Simulación matemática del nivel
    const int mockLevel = 3; // Nivel Dinámico simulado
    const int mockGold = 150;
    const int mockEscrow =
        0; // Cambia esto a un valor > 0 para probar la UI de penalización

    return Scaffold(
      // Nota Arquitectónica: Si mantienes el AppBar global en AppShell,
      // puedes omitir este para evitar doble encabezado, pero lo mantenemos según tu cascarón.
      appBar: AppBar(
        title: const Text('Perfil y Recompensas'),
        elevation: 0,
        backgroundColor: AppColors.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Placeholder para el Nivel Dinámico y Avatar
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rango Actual',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Nivel $mockLevel',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 2. Placeholder para la Barra de XP
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Experiencia (XP)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$mockXp / $mockNextLevelXp',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: mockXp / mockNextLevelXp, // Progreso simulado
                minHeight: 12,
                backgroundColor: AppColors.surface,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 3. Contenedor resaltado para el Balance de Oro y Escrow XP
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  // Si hay deuda, el borde se vuelve de advertencia o error
                  color: mockGold < 0
                      ? AppColors.error
                      : AppColors.warning.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.monetization_on,
                            color: mockGold < 0
                                ? AppColors.error
                                : AppColors.warning,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Balance de Oro',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$mockGold G',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: mockGold < 0
                              ? AppColors.error
                              : AppColors.warning,
                        ),
                      ),
                    ],
                  ),

                  // Indicador de "Escrow XP" (Solo visible si hay balance retenido)
                  if (mockEscrow > 0 || mockGold < 0) ...[
                    const Divider(color: AppColors.background, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.lock_clock,
                              color: AppColors.error,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'XP Retenida (Escrow)',
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$mockEscrow XP',
                          style: const TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 4. Mercado de Recompensas (Mockup visual extra para dar contexto)
            const Text(
              'Recompensas Disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildRewardCard('1 Hora de Xbox Series S', 50),
                  _buildRewardCard('Permiso para comida trampa', 150),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar local para mantener limpio el método build
  Widget _buildRewardCard(String title, int cost) {
    return Card(
      color: AppColors.background,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.surface, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(Icons.gamepad, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '-$cost G',
            style: const TextStyle(
              color: AppColors.warning,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
