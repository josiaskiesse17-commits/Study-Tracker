class Project {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String status;
  final DateTime? deadline;
  final DateTime createdAt;

  const Project({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.status,
    this.deadline,
    required this.createdAt,
  });

  Project copyWith({
    String? name,
    String? description,
    String? status,
    DateTime? deadline,
  }) {
    return Project(
      id: id,
      userId: userId,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt,
    );
  }
}