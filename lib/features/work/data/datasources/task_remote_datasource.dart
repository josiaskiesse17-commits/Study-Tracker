import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/write_error_reporter.dart';
import '../models/task_model.dart';

class TaskRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _getUid() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('You must be logged in to access work items.');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> _workItemsCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('workItems');
  }

  Future<List<TaskModel>> getTasks() async {
    final uid = _getUid();
    final snapshot = await _workItemsCollection(uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TaskModel.fromFirestore(doc))
        .toList();
  }

  Future<TaskModel> createTask({
    required String title,
    String? description,
    String? courseId,
    String? projectId,
    String type = 'other',
    String status = 'pending',
    String priority = 'medium',
    DateTime? dueDate,
  }) async {
    final uid = _getUid();
    final docRef = _workItemsCollection(uid).doc();

    final task = TaskModel(
      id: docRef.id,
      userId: uid,
      courseId: courseId,
      projectId: projectId,
      title: title,
      description: description,
      type: type,
      status: status,
      priority: priority,
      dueDate: dueDate,
      createdAt: DateTime.now(),
    );

    // Not awaited on purpose: offline, the server acknowledgement only comes
    // later, and waiting for it would freeze the UI.
    unawaited(
      docRef.set(task.toFirestore()).catchError((Object error) {
        debugPrint('Error creating work item: $error');
        reportWriteError(error);
      }),
    );

    return task;
  }

  Future<void> updateTask({
    required String taskId,
    required String title,
    String? description,
    String? courseId,
    String? projectId,
    required String type,
    required String status,
    required String priority,
    DateTime? dueDate,
  }) async {
    final uid = _getUid();

    unawaited(
      _workItemsCollection(uid).doc(taskId).update({
        'title': title,
        'description': description,
        'courseId': courseId,
        'projectId': projectId,
        'type': type,
        'status': status,
        'priority': priority,
        'dueDate': dueDate?.toIso8601String().split('T').first,
      }).catchError((Object error) {
        debugPrint('Error updating work item: $error');
        reportWriteError(error);
      }),
    );
  }

  Future<void> deleteTask(String taskId) async {
    final uid = _getUid();

    unawaited(
      _workItemsCollection(uid).doc(taskId).delete().catchError((Object error) {
        debugPrint('Error deleting work item: $error');
        reportWriteError(error);
      }),
    );
  }
}