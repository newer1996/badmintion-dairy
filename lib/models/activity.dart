enum ActivityStatus { pending, registered, completed, cancelled }

class Activity {
  final String id;
  final String orgId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String? location;
  final double? costEstimate;
  final ActivityStatus status;
  final String? note;
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.orgId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.location,
    this.costEstimate,
    this.status = ActivityStatus.pending,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orgId': orgId,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'costEstimate': costEstimate,
      'status': status.index,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      orgId: map['orgId'],
      date: DateTime.parse(map['date']),
      startTime: map['startTime'],
      endTime: map['endTime'],
      location: map['location'],
      costEstimate: map['costEstimate']?.toDouble(),
      status: ActivityStatus.values[map['status']],
      note: map['note'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Activity copyWith({
    String? id,
    String? orgId,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? location,
    double? costEstimate,
    ActivityStatus? status,
    String? note,
    DateTime? createdAt,
  }) {
    return Activity(
      id: id ?? this.id,
      orgId: orgId ?? this.orgId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      costEstimate: costEstimate ?? this.costEstimate,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get statusText {
    switch (status) {
      case ActivityStatus.pending:
        return '未报名';
      case ActivityStatus.registered:
        return '已报名';
      case ActivityStatus.completed:
        return '已打完';
      case ActivityStatus.cancelled:
        return '已取消';
    }
  }

  Color get statusColor {
    switch (status) {
      case ActivityStatus.pending:
        return const Color(0xFFFFC300);
      case ActivityStatus.registered:
        return const Color(0xFF07C160);
      case ActivityStatus.completed:
        return const Color(0xFF999999);
      case ActivityStatus.cancelled:
        return const Color(0xFFFA5151);
    }
  }
}