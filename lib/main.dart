import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/exercise_provider.dart';
import 'providers/timer_provider.dart';
import 'screens/home_screen.dart';
import 'screens/exercises_screen.dart';
import 'screens/timer_screen.dart';
import 'theme.dart';

void main() {
  runApp(const GymTrackerApp());
}

class GymTrackerApp extends StatelessWidget {
  const GymTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExerciseProvider()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
      ],
      child: MaterialApp(
        title: 'GymTracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const _RootNav(),
      ),
    );
  }
}

class _RootNav extends StatefulWidget {
  const _RootNav();

  @override
  State<_RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<_RootNav> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    ExercisesScreen(),
    TimerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.surfaceHigh, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Pulpit',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_outlined),
              activeIcon: Icon(Icons.fitness_center),
              label: 'Ćwiczenia',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timer_outlined),
              activeIcon: Icon(Icons.timer_rounded),
              label: 'Timer',
            ),
          ],
        ),
      ),
    );
  }
}
