import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../providers/exercise_provider.dart';
import '../theme.dart';
import 'exercise_detail_screen.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  String _search = '';
  String? _filterCategory;

  void _showAddDialog(BuildContext ctx) {
    final nameCtrl = TextEditingController();
    String selectedCategory = kCategories.first;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: StatefulBuilder(
          builder: (ctx, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nowe ćwiczenie',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.text)),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                style: const TextStyle(color: AppTheme.text),
                decoration: const InputDecoration(
                  labelText: 'Nazwa ćwiczenia',
                  prefixIcon:
                      Icon(Icons.fitness_center, color: AppTheme.textMid),
                ),
              ),
              const SizedBox(height: 16),
              Text('Kategoria',
                  style: TextStyle(color: AppTheme.textMid, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kCategories
                    .map((cat) => GestureDetector(
                          onTap: () => setState(() => selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: selectedCategory == cat
                                  ? AppTheme.accent
                                  : AppTheme.surfaceHigh,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(cat,
                                style: TextStyle(
                                  color: selectedCategory == cat
                                      ? AppTheme.bg
                                      : AppTheme.textMid,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    context.read<ExerciseProvider>().addExercise(
                        nameCtrl.text.trim(), selectedCategory);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: AppTheme.bg,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Dodaj',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExerciseProvider>();
    final exercises = provider.exercises.where((e) {
      final matchSearch =
          e.name.toLowerCase().contains(_search.toLowerCase());
      final matchCategory =
          _filterCategory == null || e.category == _filterCategory;
      return matchSearch && matchCategory;
    }).toList();

    final byCategory = <String, List<Exercise>>{};
    for (final e in exercises) {
      byCategory.putIfAbsent(e.category, () => []).add(e);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ćwiczenia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 26),
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: AppTheme.text),
              decoration: const InputDecoration(
                hintText: 'Szukaj ćwiczenia...',
                prefixIcon: Icon(Icons.search, color: AppTheme.textMid),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _CategoryChip(
                  label: 'Wszystkie',
                  selected: _filterCategory == null,
                  onTap: () => setState(() => _filterCategory = null),
                ),
                ...kCategories.map((cat) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _CategoryChip(
                        label: cat,
                        selected: _filterCategory == cat,
                        onTap: () => setState(() => _filterCategory =
                            _filterCategory == cat ? null : cat),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: exercises.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fitness_center,
                            size: 64, color: AppTheme.textLow),
                        const SizedBox(height: 16),
                        Text('Brak ćwiczeń',
                            style: TextStyle(
                                color: AppTheme.textMid, fontSize: 16)),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    children: byCategory.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 16, 0, 8),
                            child: Text(entry.key,
                                style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.accent,
                                    letterSpacing: 1.2)),
                          ),
                          ...entry.value.map((ex) => _ExerciseCard(ex)),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent : AppTheme.surfaceHigh,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
              color: selected ? AppTheme.bg : AppTheme.textMid,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            )),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  const _ExerciseCard(this.exercise);

  @override
  Widget build(BuildContext context) {
    final latest = exercise.latestEntry;
    final max = exercise.maxWeight;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key(exercise.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: AppTheme.danger.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete_outline, color: AppTheme.danger),
        ),
        confirmDismiss: (_) async {
          return await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppTheme.surface,
                  title: const Text('Usuń ćwiczenie',
                      style: TextStyle(color: AppTheme.text)),
                  content: Text('Czy na pewno usunąć "${exercise.name}"?',
                      style: const TextStyle(color: AppTheme.textMid)),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Anuluj',
                            style: TextStyle(color: AppTheme.textMid))),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Usuń',
                            style: TextStyle(color: AppTheme.danger))),
                  ],
                ),
              ) ??
              false;
        },
        onDismissed: (_) {
          context.read<ExerciseProvider>().deleteExercise(exercise.id);
        },
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ExerciseDetailScreen(exercise: exercise)),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.surfaceHigh, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.fitness_center,
                      color: AppTheme.accent, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exercise.name,
                          style: const TextStyle(
                              color: AppTheme.text,
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                      if (latest != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${latest.weight} kg · ${latest.sets}×${latest.reps}',
                          style: const TextStyle(
                              color: AppTheme.textMid, fontSize: 13),
                        ),
                      ] else
                        const Text('Brak historii',
                            style: TextStyle(
                                color: AppTheme.textLow, fontSize: 13)),
                    ],
                  ),
                ),
                if (max != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('MAX',
                          style: TextStyle(
                              color: AppTheme.accentDim,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1)),
                      Text('${max.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                              color: AppTheme.accent,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right,
                    color: AppTheme.textLow, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
