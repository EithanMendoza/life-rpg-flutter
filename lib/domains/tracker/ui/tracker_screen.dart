import 'package:flutter/material.dart';
import 'widgets/habit_card.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  // Lista de prueba (Mock Data) para visualizar la UI en dimensiones reales
  final List<Map<String, dynamic>> _mockHabits = [
    {'title': 'Series de bicicleta', 'baseXp': 15, 'isCompleted': true},
    {'title': 'Práctica de Duolingo', 'baseXp': 10, 'isCompleted': false},
    {
      'title': 'Escuchar Slow English Podcast',
      'baseXp': 20,
      'isCompleted': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Añadimos padding superior e inferior para que el último elemento
      // no quede oculto detrás de la barra de navegación
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      itemCount: _mockHabits.length,
      itemBuilder: (context, index) {
        final habit = _mockHabits[index];
        return HabitCard(
          title: habit['title'],
          baseXp: habit['baseXp'],
          isCompleted: habit['isCompleted'],
        );
      },
    );
  }
}
