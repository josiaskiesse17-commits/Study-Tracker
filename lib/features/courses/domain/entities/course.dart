class Course {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final double progress;
  final DateTime createdAt;

  const Course({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.progress,
    required this.createdAt,
  });
}