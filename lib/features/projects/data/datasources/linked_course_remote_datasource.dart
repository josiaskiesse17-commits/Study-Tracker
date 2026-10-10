import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/write_error_reporter.dart';
import '../models/linked_course_model.dart';

class LinkedCourseRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _getUid() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('You must be logged in to access project courses.');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> _linkedCoursesCollection(
    String uid,
    String projectId,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('projects')
        .doc(projectId)
        .collection('linkedCourses');
  }

  Future<List<LinkedCourseModel>> getLinkedCourses(
    String projectId,
  ) async {
    final uid = _getUid();
    final snapshot = await _linkedCoursesCollection(uid, projectId).get();

    return snapshot.docs
        .map((doc) => LinkedCourseModel.fromFirestore(doc))
        .toList();
  }

  Future<void> linkCourse(String projectId, String courseId) async {
    final uid = _getUid();
    final docRef = _linkedCoursesCollection(uid, projectId).doc(courseId);

    // Not awaited on purpose: offline, the server acknowledgement only comes
    // later, and waiting for it would freeze the UI.
    unawaited(
      docRef.set({
        'linkedAt': Timestamp.fromDate(DateTime.now()),
      }).catchError((Object error) {
        debugPrint('Error linking course: $error');
        reportWriteError(error);
      }),
    );
  }

  Future<void> unlinkCourse(String projectId, String courseId) async {
    final uid = _getUid();

    // Not awaited on purpose: offline, the server acknowledgement only comes
    // later, and waiting for it would freeze the UI.
    unawaited(
      _linkedCoursesCollection(uid, projectId)
          .doc(courseId)
          .delete()
          .catchError((Object error) {
        debugPrint('Error unlinking course: $error');
        reportWriteError(error);
      }),
    );
  }
}