enum MatchType { singles, doubles, mixed }
enum Intensity { low, medium, high }
enum Mood { great, good, tired, exhausted }

class Record {
  final String id;
  final String? activityId;
  final String orgId;
  final DateTime date;
  final double duration;
  final Map<String, double> costs;
  final Intensity intensity;
  final int calories;
  final MatchType matchType;
  final int wins;
  final int losses;
  final Mood mood;
  final String? note;
  final DateTime createdAt;

  Record({
    required this.id,
    this.activityId,
    required this.orgId,
    required this.date,
    required this.duration,
    required this.costs,
    this.intensity = Intensity.medium,
    required this.calories,
    this.matchType = MatchType.doubles,
    this.wins = 0,
    this.losses = 0,
    this.mood = Mood.good,
    this.note,
    required this.createdAt,
  });

  double get totalCost {
    return (costs['court'] ?? 0) +
        (costs['shuttlecock'] ?? 0) +
        (costs['drinks'] ?? 0) +
        (costs['other'] ?? 0);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activityId': activityId,
      'orgId': orgId,
      'date': date.toIso8601String(),
      'duration': duration,
      'costs': costs,
      'intensity': intensity.index,
      'calories': calories,
      'matchType': matchType.index,
      'wins': wins,
      'losses': losses,
      'mood': mood.index,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Record.fromMap(Map<String, dynamic> map) {
    return Record(
      id: map['id'],
      activityId: map['activityId'],
      orgId: map['orgId'],
      date: DateTime.parse(map['date']),
      duration: map['duration'].toDouble(),
      costs: Map<String, double>.from(map['costs'] ?? {}),
      intensity: Intensity.values[map['intensity']],
      calories: map['calories'],
      matchType: MatchType.values[map['matchType']],
      wins: map['wins'],
      losses: map['losses'],
      mood: Mood.values[map['mood']],
      note: map['note'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}