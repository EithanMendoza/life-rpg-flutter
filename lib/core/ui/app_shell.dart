import 'package:flutter/material.dart';
import '../../domains/tracker/ui/screens/tracker_screen.dart';
import '../../domains/gamification/ui/gamification_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  // 2. Reemplazamos el primer placeholder (Center) por nuestra TrackerScreen
  final List<Widget> _screens = const [
    TrackerScreen(), // <- La pantalla real del dominio de hábitos
    // Dejamos los demás placeholders intactos para el siguiente Sprint
    GamificationScreen(), // <- La pantalla real del dominio de gamificación
    Center(
      child: Text(
        'Pantalla de Perfil\n(Auth & Settings)',
        textAlign: TextAlign.center,
      ),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Life RPG')),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).textTheme.bodyMedium?.color,
        backgroundColor: Theme.of(context).colorScheme.surface,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            activeIcon: Icon(Icons.check_circle),
            label: 'Hábitos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events),
            label: 'Recompensas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
