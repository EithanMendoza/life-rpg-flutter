import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/tracker_provider.dart';
import '../../../../core/providers/session_provider.dart'; // Tu puente de identidad

class HabitCard extends ConsumerStatefulWidget {
  final String id;
  final String title;
  final int baseXp;
  final bool isCompleted;
  final String? syncStatus;
  final String? clientTimestamp;

  const HabitCard({
    super.key,
    required this.id,
    required this.title,
    required this.baseXp,
    this.isCompleted = false,
    this.syncStatus,
    this.clientTimestamp,
  });

  @override
  ConsumerState<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends ConsumerState<HabitCard> {
  Timer? _timer;
  int _remainingSeconds = 0;
  static const int _undoWindowSeconds = 900; // 15 minutos exactos

  @override
  void initState() {
    super.initState();
    _checkUndoStatus();
  }

  @override
  void didUpdateWidget(HabitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.syncStatus != oldWidget.syncStatus ||
        widget.clientTimestamp != oldWidget.clientTimestamp) {
      _checkUndoStatus();
    }
  }

  void _checkUndoStatus() {
    _timer?.cancel();
    if (widget.syncStatus == 'pending_undo' && widget.clientTimestamp != null) {
      final logTime = DateTime.parse(widget.clientTimestamp!).toLocal();
      final now = DateTime.now();
      final elapsed = now.difference(logTime).inSeconds;
      final remaining = _undoWindowSeconds - elapsed;

      if (remaining > 0) {
        setState(() {
          _remainingSeconds = remaining;
        });
        _startTimer();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _finalizeCommit();
        });
      }
    } else {
      setState(() {
        _remainingSeconds = 0;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        _finalizeCommit();
      }
    });
  }

  Future<void> _finalizeCommit() async {
    final userId = ref.read(localUserIdProvider).value;
    if (userId == null) return;

    await ref
        .read(trackerControllerProvider.notifier)
        .commitAction(habitId: widget.id);

    // Invalida la lista del usuario REAL
    ref.invalidate(habitsProvider(userId));
  }

  Future<void> _undoAction() async {
    _timer?.cancel();
    final userId = ref.read(localUserIdProvider).value;
    if (userId == null) return;

    await ref
        .read(trackerControllerProvider.notifier)
        .undoAction(habitId: widget.id);

    // Invalida la lista del usuario REAL
    ref.invalidate(habitsProvider(userId));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds / 60).floor();
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isPendingUndo = widget.syncStatus == 'pending_undo';
    final bool isFullyCompleted = widget.isCompleted && !isPendingUndo;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPendingUndo
              ? AppColors.warning.withOpacity(0.5)
              : isFullyCompleted
              ? AppColors.primary.withOpacity(0.5)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: InkWell(
              onTap: () async {
                if (widget.isCompleted || isPendingUndo) return;

                // 1. Buscamos al usuario real
                final userId = ref.read(localUserIdProvider).value;
                if (userId == null) return;

                final int timezoneOffset =
                    DateTime.now().timeZoneOffset.inMinutes;

                // 2. Disparamos el evento real
                await ref
                    .read(trackerControllerProvider.notifier)
                    .registerAction(
                      userId: userId, // ¡Adiós 'shadow-account-id'!
                      actionType: 'habit_completed:${widget.id}',
                      timezoneOffset: timezoneOffset,
                    );

                // 3. Refrescamos la UI real
                ref.invalidate(habitsProvider(userId));
              },
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isPendingUndo
                          ? AppColors.warning
                          : isFullyCompleted
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      width: 2,
                    ),
                    color: isPendingUndo
                        ? AppColors.warning.withOpacity(0.2)
                        : isFullyCompleted
                        ? AppColors.primary.withOpacity(0.2)
                        : Colors.transparent,
                  ),
                  child: isPendingUndo
                      ? const Icon(
                          Icons.access_time,
                          size: 18,
                          color: AppColors.warning,
                        )
                      : isFullyCompleted
                      ? const Icon(
                          Icons.check,
                          size: 18,
                          color: AppColors.primary,
                        )
                      : null,
                ),
              ),
            ),
            title: Text(
              widget.title,
              style: TextStyle(
                color: widget.isCompleted
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
                decoration: widget.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isPendingUndo
                    ? AppColors.warning.withOpacity(0.1)
                    : isFullyCompleted
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '+${widget.baseXp} XP',
                style: TextStyle(
                  color: isPendingUndo
                      ? AppColors.warning
                      : isFullyCompleted
                      ? AppColors.primary
                      : AppColors.warning,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          // BARRA INFERIOR DE DESHACER
          if (isPendingUndo)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Guardando en $_formattedTime',
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  TextButton(
                    onPressed: _undoAction,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(60, 30),
                    ),
                    child: const Text('Deshacer'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
