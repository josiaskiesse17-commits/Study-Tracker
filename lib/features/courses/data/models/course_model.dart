import '../../domain/entities/course.dart';

class CourseModel extends Course {
  const CourseModel({
    required super.id,
    required super.userId,
    required super.name,
    super.description,
    required super.progress,
    required super.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(
        json['created_at'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'progress': progress,
      'created_at': createdAt.toIso8601String(),
    };
  }
}