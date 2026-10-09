import 'package:cloud_firestore/cloud_firestore.dart';
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

  factory TaskModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return TaskModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      courseId: data['courseId'] as String?,
      projectId: data['projectId'] as String?,
      title: data['title'] as String? ?? '',
      description: data['description'] as String?,
      type: data['type'] as String? ?? 'other',
      status: data['status'] as String? ?? 'pending',
      priority: data['priority'] as String? ?? 'medium',
      dueDate: data['dueDate'] != null
          ? DateTime.parse(data['dueDate'] as String)
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'courseId': courseId,
      'projectId': projectId,
      'title': title,
      'description': description,
      'type': type,
      'status': status,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String().split('T').first,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}