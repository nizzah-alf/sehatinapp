class Activity {
  final int id;
  final String description;
  final bool isDone;
  final String? userId;
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.description,
    required this.isDone,
    this.userId,
    required this.createdAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
      isDone: json['is_done'] == true || json['is_done'] == 1,
      userId: json['user_id']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

extension ActivityCopy on Activity {
  Activity copyWith({
    int? id,
    String? description,
    bool? isDone,
    String? userId,
    DateTime? createdAt,
  }) {
    return Activity(
      id: id ?? this.id,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
