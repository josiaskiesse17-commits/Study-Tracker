class Task {
  final String id;
  final String userId;
  final String? courseId;
  final String title;
  final String? description;
  final bool completed;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.userId,
    this.courseId,
    required this.title,
    this.description,
    required this.completed,
    required this.createdAt,
  });

  Task copyWith({
    String? title,
    String? description,
    String? courseId,
    bool? completed,
  }) {
    return Task(
      id: id,
      userId: userId,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      createdAt: createdAt,
    );
  }
}