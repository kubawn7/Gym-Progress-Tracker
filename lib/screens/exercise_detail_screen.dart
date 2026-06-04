import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../providers/exercise_provider.dart';
import '../theme.dart';
import 'timer_screen.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;
  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  void _showAddEntryDialog() {
    final weightCtrl = TextEditingController();
    final repsCtrl = TextEditingController(text: '8');
    final setsCtrl = TextEditingController(text: '3');
    final noteCtrl = TextEditingController();

    // Pre-fill with last entry
    final latest = widget.exercise.latestEntry;
    if (latest != null) {
      weightCtrl.text = latest.weight.toString();
      repsCtrl.text = latest.reps.toString();
      setsCtrl.text = latest.sets.toString();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dodaj wynik',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.text)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: weightCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: AppTheme.text),
                    decoration: const InputDecoration(
                      labelText: 'Ciężar (kg)',
                      prefixIcon: Icon(Icons.monitor_weight_outlined,
                          color: AppTheme.textMid),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: setsCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppTheme.text),
                    decoration: const InputDecoration(labelText: 'Serie'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: repsCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppTheme.text),
                    decoration: const InputDecoration(labelText: 'Powtórzenia'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              style: const TextStyle(color: AppTheme.text),
              decoration: const InputDecoration(
                labelText: 'Notatka (opcjonalna)',
                prefixIcon:
                    Icon(Icons.edit_note, color: AppTheme.textMid),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final weight = double.tryParse(weightCtrl.text);
                  final reps = int.tryParse(repsCtrl.text);
                  final sets = int.tryParse(setsCtrl.text);
                  if (weight == null || reps == null || sets == null) return;
                  context.read<ExerciseProvider>().addEntry(
                      widget.exercise.id, weight, reps, sets,
                      note: noteCtrl.text.trim().isEmpty
                          ? null
                          : noteCtrl.text.trim());
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: AppTheme.bg,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Zapisz wynik',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider to rebuild on changes
    context.watch<ExerciseProvider>();
    final ex = widget.exercise;
    final history = List<WeightEntry>.from(ex.history.reversed);

    return Scaffold(
      appBar: AppBar(
        title: Text(ex.name),
        actions: [
          IconButton(
            tooltip: 'Timer odpoczynku',
            icon: const Icon(Icons.timer_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const TimerScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats bar
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.surfaceHigh),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(
                  label: 'AKTUALNY',
                  value: ex.latestEntry != null
                      ? '${ex.latestEntry!.weight} kg'
                      : '—',
                  highlight: false,
                ),
                Container(width: 1, height: 40, color: AppTheme.surfaceHigh),
                _Stat(
                  label: 'REKORD',
                  value: ex.maxWeight != null
                      ? '${ex.maxWeight!.toStringAsFixed(1)} kg'
                      : '—',
                  highlight: true,
                ),
                Container(width: 1, height: 40, color: AppTheme.surfaceHigh),
                _Stat(
                  label: 'SESJE',
                  value: '${ex.history.length}',
                  highlight: false,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Text('Historia',
                    style: GoogleFonts.spaceGrotesk(
                        color: AppTheme.textMid,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1)),
              ],
            ),
          ),
          Expanded(
            child: history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bar_chart, size: 64, color: AppTheme.textLow),
                        const SizedBox(height: 12),
                        Text('Brak historii. Dodaj pierwszy wynik!',
                            style: TextStyle(
                                color: AppTheme.textMid, fontSize: 15)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final entry = history[i];
                      final realIndex = ex.history.length - 1 - i;
                      final isLatest = i == 0;
                      return _HistoryTile(
                        entry: entry,
                        isLatest: isLatest,
                        onDelete: () {
                          context
                              .read<ExerciseProvider>()
                              .deleteEntry(ex.id, realIndex);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEntryDialog,
        icon: const Icon(Icons.add),
        label: const Text('Dodaj wynik',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _Stat(
      {required this.label, required this.value, required this.highlight});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                color: highlight ? AppTheme.accentDim : AppTheme.textLow,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: highlight ? AppTheme.accent : AppTheme.text,
                fontSize: 22,
                fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final WeightEntry entry;
  final bool isLatest;
  final VoidCallback onDelete;

  const _HistoryTile(
      {required this.entry, required this.isLatest, required this.onDelete});

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('${entry.date.toIso8601String()}'),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: AppTheme.danger.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: AppTheme.danger),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLatest
              ? AppTheme.accent.withOpacity(0.07)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isLatest ? AppTheme.accent.withOpacity(0.3) : AppTheme.surfaceHigh,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(_formatDate(entry.date),
                          style: const TextStyle(
                              color: AppTheme.textMid, fontSize: 12)),
                      if (isLatest) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('OSTATNI',
                              style: TextStyle(
                                  color: AppTheme.accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5)),
                        ),
                      ]
                    ],
                  ),
                  if (entry.note != null) ...[
                    const SizedBox(height: 4),
                    Text(entry.note!,
                        style: const TextStyle(
                            color: AppTheme.textMid, fontSize: 13)),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${entry.weight} kg',
                    style: const TextStyle(
                        color: AppTheme.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                Text('${entry.sets}×${entry.reps} powt.',
                    style: const TextStyle(
                        color: AppTheme.textMid, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
