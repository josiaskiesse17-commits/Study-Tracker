import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/course_model.dart';

class CourseRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _getUid() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('You must be logged in to access courses.');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> _coursesCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('courses');
  }

  Future<List<CourseModel>> getCourses() async {
    final uid = _getUid();
    final snapshot = await _coursesCollection(uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => CourseModel.fromFirestore(doc))
        .toList();
  }

  Future<CourseModel> getCourse(String courseId) async {
    final uid = _getUid();
    final doc = await _coursesCollection(uid).doc(courseId).get();

    if (!doc.exists) {
      throw Exception('Course not found');
    }

    return CourseModel.fromFirestore(doc);
  }

  Future<CourseModel> createCourse({
    required String name,
    String? description,
    double progress = 0,
  }) async {
    final uid = _getUid();
    final docRef = _coursesCollection(uid).doc();

    final course = CourseModel(
      id: docRef.id,
      userId: uid,
      name: name,
      description: description,
      progress: progress,
      createdAt: DateTime.now(),
    );

    // Not awaited on purpose: offline, the server acknowledgement only comes
    // later, and waiting for it would freeze the UI.
    unawaited(
      docRef.set(course.toFirestore()).catchError((Object error) {
        debugPrint('Error creating course: $error');
      }),
    );

    return course;
  }

  Future<void> updateCourse({
    required String courseId,
    required String name,
    String? description,
    required double progress,
  }) async {
    final uid = _getUid();

    unawaited(
      _coursesCollection(uid).doc(courseId).update({
        'name': name,
        'description': description,
        'progress': progress,
      }).catchError((Object error) {
        debugPrint('Error updating course: $error');
      }),
    );
  }

  Future<void> deleteCourse(String courseId) async {
    final uid = _getUid();

    unawaited(
      _coursesCollection(uid).doc(courseId).delete().catchError((Object error) {
        debugPrint('Error deleting course: $error');
      }),
    );
  }
}