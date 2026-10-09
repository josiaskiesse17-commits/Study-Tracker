import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/project.dart';

class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.userId,
    required super.name,
    super.description,
    required super.status,
    super.deadline,
    required super.createdAt,
  });

  factory ProjectModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ProjectModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      status: data['status'] as String? ?? 'planning',
      deadline: data['deadline'] != null
          ? DateTime.parse(data['deadline'] as String)
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'status': status,
      'deadline': deadline?.toIso8601String().split('T').first,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}