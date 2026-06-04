import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../providers/exercise_provider.dart';
import '../providers/timer_provider.dart';
import '../theme.dart';
import 'exercise_detail_screen.dart';
import 'timer_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExerciseProvider>();
    final timer = context.watch<TimerProvider>();
    final exercises = provider.exercises;

    // Recent 5 exercises that have history
    final recent = exercises
        .where((e) => e.history.isNotEmpty)
        .toList()
      ..sort((a, b) =>
          b.latestEntry!.date.compareTo(a.latestEntry!.date));
    final recentTop = recent.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style: GoogleFonts.spaceGrotesk(
                fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.text),
            children: [
              const TextSpan(text: 'GYM'),
              TextSpan(
                  text: 'TRACKER',
                  style: TextStyle(color: AppTheme.accent)),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        children: [
          // Timer mini widget
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const TimerScreen())),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: timer.state == TimerState.running
                      ? [
                          AppTheme.accent.withOpacity(0.15),
                          AppTheme.surfaceHigh
                        ]
                      : [AppTheme.surface, AppTheme.surfaceHigh],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: timer.state == TimerState.running
                      ? AppTheme.accent.withOpacity(0.4)
                      : AppTheme.surfaceHigh,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.timer_outlined,
                        color: AppTheme.accent, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Timer przerwy',
                            style: const TextStyle(
                                color: AppTheme.textMid,
                                fontSize: 12,
                                letterSpacing: 0.5)),
                        Text(
                          timer.state == TimerState.idle
                              ? 'Dotknij, aby uruchomić'
                              : timer.timeString,
                          style: GoogleFonts.spaceGrotesk(
                            color: timer.state == TimerState.running
                                ? AppTheme.accent
                                : AppTheme.text,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    timer.state == TimerState.running
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: AppTheme.accent,
                    size: 36,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Ćwiczenia',
                  value: '${exercises.length}',
                  icon: Icons.fitness_center,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Sesje treningowe',
                  value: '${exercises.fold(0, (s, e) => s + e.history.length)}',
                  icon: Icons.bar_chart,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          if (recentTop.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 14),
              child: Text('OSTATNIO TRENOWANE',
                  style: TextStyle(
                      color: AppTheme.textMid,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5)),
            ),
            ...recentTop.map((ex) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RecentExerciseTile(ex),
                )),
          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  children: [
                    Icon(Icons.directions_run,
                        size: 64, color: AppTheme.textLow),
                    const SizedBox(height: 12),
                    Text('Zacznij trenować!',
                        style: GoogleFonts.spaceGrotesk(
                            color: AppTheme.textMid,
                            fontSize: 18,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(
                        'Przejdź do zakładki Ćwiczenia\ni dodaj swój pierwszy wynik',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppTheme.textLow, fontSize: 14)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.surfaceHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.accent, size: 22),
          const SizedBox(height: 10),
          Text(value,
              style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.text,
                  fontSize: 28,
                  fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(color: AppTheme.textMid, fontSize: 12)),
        ],
      ),
    );
  }
}

class _RecentExerciseTile extends StatelessWidget {
  final Exercise exercise;
  const _RecentExerciseTile(this.exercise);

  @override
  Widget build(BuildContext context) {
    final latest = exercise.latestEntry!;
    final daysAgo =
        DateTime.now().difference(latest.date).inDays;
    final when = daysAgo == 0
        ? 'Dzisiaj'
        : daysAgo == 1
            ? 'Wczoraj'
            : '$daysAgo dni temu';

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ExerciseDetailScreen(exercise: exercise))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.surfaceHigh),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: AppTheme.surfaceHigh,
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.fitness_center,
                  color: AppTheme.accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.name,
                      style: const TextStyle(
                          color: AppTheme.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  Text(when,
                      style: const TextStyle(
                          color: AppTheme.textMid, fontSize: 12)),
                ],
              ),
            ),
            Text('${latest.weight} kg',
                style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(width: 4),
            Text('${latest.sets}×${latest.reps}',
                style: const TextStyle(
                    color: AppTheme.textMid, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
