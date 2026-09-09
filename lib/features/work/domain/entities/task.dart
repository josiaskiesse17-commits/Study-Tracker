class WorkItem {
  final String id;
  final String userId;
  final String? courseId;
  final String? projectId;
  final String title;
  final String? description;
  final String type;
  final String status;
  final String priority;
  final DateTime? dueDate;
  final DateTime createdAt;

  const WorkItem({
    required this.id,
    required this.userId,
    this.courseId,
    this.projectId,
    required this.title,
    this.description,
    required this.type,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.createdAt,
  });

  WorkItem copyWith({
    String? title,
    String? description,
    String? courseId,
    String? projectId,
    String? type,
    String? status,
    String? priority,
    DateTime? dueDate,
  }) {
    return WorkItem(
      id: id,
      userId: userId,
      courseId: courseId ?? this.courseId,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt,
    );
  }
}