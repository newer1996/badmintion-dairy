class Organization {
  final String id;
  final String name;
  final String? defaultLocation;
  final double? defaultCost;
  final DateTime createdAt;

  Organization({
    required this.id,
    required this.name,
    this.defaultLocation,
    this.defaultCost,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'defaultLocation': defaultLocation,
      'defaultCost': defaultCost,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Organization.fromMap(Map<String, dynamic> map) {
    return Organization(
      id: map['id'],
      name: map['name'],
      defaultLocation: map['defaultLocation'],
      defaultCost: map['defaultCost']?.toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Organization copyWith({
    String? id,
    String? name,
    String? defaultLocation,
    double? defaultCost,
    DateTime? createdAt,
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultLocation: defaultLocation ?? this.defaultLocation,
      defaultCost: defaultCost ?? this.defaultCost,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}