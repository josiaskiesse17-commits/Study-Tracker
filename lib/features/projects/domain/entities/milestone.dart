class Milestone {
  final String id;
  final String projectId;
  final String title;
  final String? description;
  final String status;
  final DateTime? dueDate;
  final DateTime createdAt;

  const Milestone({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    required this.status,
    this.dueDate,
    required this.createdAt,
  });

  Milestone copyWith({
    String? title,
    String? description,
    String? status,
    DateTime? dueDate,
  }) {
    return Milestone(
      id: id,
      projectId: projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt,
    );
  }
}