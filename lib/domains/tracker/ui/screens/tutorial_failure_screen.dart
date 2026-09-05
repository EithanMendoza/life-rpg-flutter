import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/tracker_provider.dart';
import '../../../../core/providers/session_provider.dart'; // Tu puente de identidad

class TutorialFailureScreen extends ConsumerStatefulWidget {
  final String tutorialStepId;

  const TutorialFailureScreen({super.key, required this.tutorialStepId});

  @override
  ConsumerState<TutorialFailureScreen> createState() =>
      _TutorialFailureScreenState();
}

class _TutorialFailureScreenState extends ConsumerState<TutorialFailureScreen> {
  bool _isInjecting = true;

  @override
  void initState() {
    super.initState();
    _executeSimulation();
  }

  Future<void> _executeSimulation() async {
    // 🚨 MAGIA DE VIDEOJUEGOS: Humo y Espejos
    // En lugar de arriesgar un bloqueo de SQLite por un evento falso,
    // simulamos el cálculo de daño visualmente durante 2 segundos.
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isInjecting = false);
    }
  }

  Future<void> _acknowledgeAndProceed() async {
    final userId = ref.read(localUserIdProvider).value;

    if (userId != null) {
      await ref
          .read(trackerControllerProvider.notifier)
          .purgeTutorialAndTransition(userId: userId);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInjecting) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.redAccent),
              SizedBox(height: 16),
              Text(
                'Simulando fallo de Trabajo Profundo...',
                style: TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF2A0808),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.favorite_border,
                size: 80,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 32),
              const Text(
                'EL PRECIO DEL FRACASO',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'La aversión a la pérdida es real.\n\nHas sentido cómo tu barra de salud reacciona al daño. En LIFE RPG, la disciplina se premia, pero la negligencia tiene consecuencias. Abandonar un temporizador de concentración o ignorar tus hábitos te costará HP.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _acknowledgeAndProceed,
                  child: const Text(
                    'Estoy Listo. Asumo el Reto.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
