import '../../domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.userId,
    super.courseId,
    required super.title,
    super.description,
    required super.completed,
    required super.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final completedValue = json['completed'];

    final bool completed;

    if (completedValue is bool) {
      completed = completedValue;
    } else if (completedValue is num) {
      completed = completedValue != 0;
    } else {
      completed = false;
    }

    return TaskModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      courseId: json['course_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      completed: completed,
      createdAt: DateTime.parse(
        json['created_at'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'title': title,
      'description': description,
      'completed': completed,
      'created_at': createdAt.toIso8601String(),
    };
  }
}