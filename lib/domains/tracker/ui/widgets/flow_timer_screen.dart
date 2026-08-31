import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Ajusta las rutas según tu estructura
import '../../models/habit.dart';
import '../../providers/tracker_provider.dart';
// import '../../../core/theme/app_colors.dart'; // Opcional si usas los tuyos

class FlowTimerScreen extends ConsumerStatefulWidget {
  final Habit habit;

  const FlowTimerScreen({super.key, required this.habit});

  @override
  ConsumerState<FlowTimerScreen> createState() => _FlowTimerScreenState();
}

// ADVERTENCIA PM: Implementamos WidgetsBindingObserver para resiliencia en background
class _FlowTimerScreenState extends ConsumerState<FlowTimerScreen>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _isRunning = false;
  int _elapsedSeconds = 0;
  DateTime? _lastTickTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(
      this,
    ); // Nos suscribimos al ciclo de vida del OS
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  // =================================================================
  // RESILIENCIA AL SEGUNDO PLANO (OOM Killer / Battery Saver)
  // =================================================================
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _isRunning &&
        _lastTickTime != null) {
      // Calculamos los segundos reales que pasaron mientras la app estaba "dormida"
      final now = DateTime.now();
      final difference = now.difference(_lastTickTime!).inSeconds;

      setState(() {
        _elapsedSeconds += difference;
        _lastTickTime = now;
      });
    }
  }

  // =================================================================
  // CONTROLES DEL CRONÓMETRO
  // =================================================================
  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() {
        _isRunning = true;
        _lastTickTime = DateTime.now();
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _elapsedSeconds++;
          _lastTickTime = DateTime.now();
        });
      });
    }
  }

  Future<void> _stopAndSave() async {
    _timer?.cancel();
    setState(() => _isRunning = false);

    if (_elapsedSeconds < 60) {
      // Opcional: Fricción para evitar spam de sesiones cortas
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La sesión debe durar al menos 1 minuto para ser registrada.',
          ),
        ),
      );
      return;
    }

    // Guardado persistente (ADR-001) a través de Riverpod
    final timezoneOffset = DateTime.now().timeZoneOffset.inHours;
    await ref
        .read(trackerControllerProvider.notifier)
        .registerAction(
          userId: widget.habit.userId,
          actionType:
              'habit_completed:${widget.habit.id}', // Gatillo estandarizado
          timezoneOffset: timezoneOffset,
        );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String get _formattedTime {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRecovery = widget.habit.isRecovery;

    // Paletas dinámicas basadas en el estado conductual del hábito
    final bgColor = isRecovery
        ? const Color(0xFF1E2A22)
        : theme.colorScheme.background;
    final accentColor = isRecovery
        ? Colors.tealAccent
        : theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ==========================================================
            // PLACEHOLDER ADR-004: Overlay de Gamificación (Multiplicador XP)
            // ==========================================================
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accentColor.withOpacity(0.5)),
                    ),
                    child: const Text(
                      'Multiplicador XP (Próximamente)',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ==========================================================
            // ZONA DE RECUPERACIÓN (Modo Taberna/Campamento)
            // ==========================================================
            if (isRecovery) ...[
              const Icon(
                Icons.fireplace_outlined,
                size: 48,
                color: Colors.orangeAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                'Sistema de penalizaciones en pausa',
                style: TextStyle(
                  color: Colors.tealAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Recupera energía. Estás en área segura.',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 48),
            ],

            Text(
              widget.habit.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isRecovery
                    ? Colors.white
                    : theme.colorScheme.onBackground,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Reloj Inmersivo
            Text(
              _formattedTime,
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.w200,
                color: accentColor,
                fontFeatures: const [
                  FontFeature.tabularFigures(),
                ], // Evita que el texto baile
              ),
            ),

            const Spacer(),

            // ==========================================================
            // CONTROLES DE FLUJO
            // ==========================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón de Detener / Guardar (Aparece cuando ya hay tiempo acumulado)
                if (_elapsedSeconds > 0) ...[
                  FloatingActionButton.large(
                    heroTag: 'stop_btn',
                    onPressed: _stopAndSave,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    foregroundColor: theme.colorScheme.error,
                    elevation: 0,
                    child: const Icon(Icons.stop_rounded, size: 36),
                  ),
                  const SizedBox(width: 32),
                ],

                // Botón Play / Pause
                FloatingActionButton.large(
                  heroTag: 'play_pause_btn',
                  onPressed: _toggleTimer,
                  backgroundColor: accentColor,
                  foregroundColor: isRecovery
                      ? Colors.black
                      : theme.colorScheme.onPrimary,
                  child: Icon(
                    _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 40,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }
}
