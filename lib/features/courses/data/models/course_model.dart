import 'package:cloud_firestore/cloud_firestore.dart';
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

  factory CourseModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return CourseModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      progress: (data['progress'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'progress': progress,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}