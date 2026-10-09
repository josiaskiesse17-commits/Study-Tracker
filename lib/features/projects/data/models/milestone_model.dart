import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/milestone.dart';

class MilestoneModel extends Milestone {
  const MilestoneModel({
    required super.id,
    required super.projectId,
    required super.title,
    super.description,
    required super.status,
    super.dueDate,
    required super.createdAt,
  });

  factory MilestoneModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return MilestoneModel(
      id: doc.id,
      projectId: data['projectId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String?,
      status: data['status'] as String? ?? 'pending',
      dueDate: data['dueDate'] != null
          ? DateTime.parse(data['dueDate'] as String)
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'title': title,
      'description': description,
      'status': status,
      'dueDate': dueDate?.toIso8601String().split('T').first,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}