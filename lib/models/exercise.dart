

class WeightEntry {
  final double weight;
  final int reps;
  final int sets;
  final DateTime date;
  final String? note;

  WeightEntry({
    required this.weight,
    required this.reps,
    required this.sets,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'weight': weight,
        'reps': reps,
        'sets': sets,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory WeightEntry.fromJson(Map<String, dynamic> json) => WeightEntry(
        weight: (json['weight'] as num).toDouble(),
        reps: json['reps'] as int,
        sets: json['sets'] as int,
        date: DateTime.parse(json['date'] as String),
        note: json['note'] as String?,
      );
}

class Exercise {
  final String id;
  String name;
  String category;
  List<WeightEntry> history;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    List<WeightEntry>? history,
  }) : history = history ?? [];

  WeightEntry? get latestEntry =>
      history.isNotEmpty ? history.last : null;

  double? get maxWeight => history.isNotEmpty
      ? history.map((e) => e.weight).reduce((a, b) => a > b ? a : b)
      : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'history': history.map((e) => e.toJson()).toList(),
      };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        history: (json['history'] as List<dynamic>)
            .map((e) => WeightEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

const List<String> kCategories = [
  'Klatka piersiowa',
  'Plecy',
  'Nogi',
  'Ramiona',
  'Barki',
  'Brzuch',
  'Całe ciało',
];
