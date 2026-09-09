import '../../domain/entities/task.dart';

class TaskModel extends WorkItem {
  const TaskModel({
    required super.id,
    required super.userId,
    super.courseId,
    super.projectId,
    required super.title,
    super.description,
    required super.type,
    required super.status,
    required super.priority,
    super.dueDate,
    required super.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      courseId: json['course_id'] as String?,
      projectId: json['project_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: json['type'] as String? ?? 'other',
      status: json['status'] as String? ?? 'pending',
      priority: json['priority'] as String? ?? 'medium',
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'project_id': projectId,
      'title': title,
      'description': description,
      'type': type,
      'status': status,
      'priority': priority,
      'due_date': dueDate?.toIso8601String().split('T').first,
      'created_at': createdAt.toIso8601String(),
    };
  }
}