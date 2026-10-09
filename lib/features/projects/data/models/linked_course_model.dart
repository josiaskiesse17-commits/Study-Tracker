import 'package:cloud_firestore/cloud_firestore.dart';

class LinkedCourseModel {
  const LinkedCourseModel({
    required this.courseId,
    required this.linkedAt,
  });

  final String courseId;
  final DateTime linkedAt;

  factory LinkedCourseModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return LinkedCourseModel(
      courseId: doc.id,
      linkedAt: (data['linkedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'linkedAt': Timestamp.fromDate(linkedAt),
    };
  }
}