import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/exercise.dart';

class ExerciseProvider extends ChangeNotifier {
  static const _key = 'exercises';
  List<Exercise> _exercises = [];
  bool _loaded = false;

  List<Exercise> get exercises => List.unmodifiable(_exercises);

  ExerciseProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      _exercises = list
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      // Seed with sample exercises
      _exercises = [
        Exercise(id: const Uuid().v4(), name: 'Wyciskanie na ławce', category: 'Klatka piersiowa'),
        Exercise(id: const Uuid().v4(), name: 'Martwy ciąg', category: 'Plecy'),
        Exercise(id: const Uuid().v4(), name: 'Przysiad ze sztangą', category: 'Nogi'),
        Exercise(id: const Uuid().v4(), name: 'Wiosłowanie sztangą', category: 'Plecy'),
        Exercise(id: const Uuid().v4(), name: 'Wyciskanie żołnierskie', category: 'Barki'),
      ];
      await _save();
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_exercises.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  bool get isLoaded => _loaded;

  List<Exercise> get(String category) =>
      _exercises.where((e) => e.category == category).toList();

  void addExercise(String name, String category) {
    _exercises.add(Exercise(
      id: const Uuid().v4(),
      name: name,
      category: category,
    ));
    _save();
    notifyListeners();
  }

  void deleteExercise(String id) {
    _exercises.removeWhere((e) => e.id == id);
    _save();
    notifyListeners();
  }

  void addEntry(String exerciseId, double weight, int reps, int sets, {String? note}) {
    final ex = _exercises.firstWhere((e) => e.id == exerciseId);
    ex.history.add(WeightEntry(
      weight: weight,
      reps: reps,
      sets: sets,
      date: DateTime.now(),
      note: note,
    ));
    _save();
    notifyListeners();
  }

  void deleteEntry(String exerciseId, int index) {
    final ex = _exercises.firstWhere((e) => e.id == exerciseId);
    ex.history.removeAt(index);
    _save();
    notifyListeners();
  }

  void renameExercise(String id, String newName) {
    final ex = _exercises.firstWhere((e) => e.id == id);
    ex.name = newName;
    _save();
    notifyListeners();
  }
}
