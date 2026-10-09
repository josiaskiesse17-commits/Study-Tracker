import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/project_model.dart';

class ProjectRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _getUid() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('You must be logged in to access projects.');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> _projectsCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('projects');
  }

  Future<List<ProjectModel>> getProjects() async {
    final uid = _getUid();
    final snapshot = await _projectsCollection(uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ProjectModel.fromFirestore(doc))
        .toList();
  }

  Future<ProjectModel> createProject({
    required String name,
    String? description,
    String status = 'planning',
    DateTime? deadline,
  }) async {
    final uid = _getUid();
    final docRef = _projectsCollection(uid).doc();

    final project = ProjectModel(
      id: docRef.id,
      userId: uid,
      name: name,
      description: description,
      status: status,
      deadline: deadline,
      createdAt: DateTime.now(),
    );

    // Not awaited on purpose: offline, the server acknowledgement only comes
    // later, and waiting for it would freeze the UI.
    unawaited(
      docRef.set(project.toFirestore()).catchError((Object error) {
        debugPrint('Error creating project: $error');
      }),
    );

    return project;
  }

  Future<void> updateProject({
    required String projectId,
    required String name,
    String? description,
    required String status,
    DateTime? deadline,
  }) async {
    final uid = _getUid();

    unawaited(
      _projectsCollection(uid).doc(projectId).update({
        'name': name,
        'description': description,
        'status': status,
        'deadline': deadline?.toIso8601String().split('T').first,
      }).catchError((Object error) {
        debugPrint('Error updating project: $error');
      }),
    );
  }

  /// Reads a query for the delete cleanup without ever throwing or hanging:
  /// server first (4 s timeout), then the local cache, otherwise null.
  Future<QuerySnapshot<Map<String, dynamic>>?> _tryGet(
    Query<Map<String, dynamic>> query,
  ) async {
    try {
      return await query.get().timeout(const Duration(seconds: 4));
    } catch (_) {
      try {
        return await query.get(const GetOptions(source: Source.cache));
      } catch (error) {
        debugPrint('Could not read data for project cleanup: $error');
        return null;
      }
    }
  }

  Future<void> deleteProject(String projectId) async {
    final uid = _getUid();
    final projectRef = _projectsCollection(uid).doc(projectId);

    final batch = _firestore.batch();

    // Milestones live in a subcollection, which Firestore does not delete
    // automatically with the project.
    final milestonesSnapshot = await _tryGet(projectRef.collection('milestones'));
    if (milestonesSnapshot != null) {
      for (final doc in milestonesSnapshot.docs) {
        batch.delete(doc.reference);
      }
    }

    // Linked courses live in a subcollection.
    final linkedCoursesSnapshot = await _tryGet(projectRef.collection('linkedCourses'));
    if (linkedCoursesSnapshot != null) {
      for (final doc in linkedCoursesSnapshot.docs) {
        batch.delete(doc.reference);
      }
    }

    // Keep the project's work items, but detach them from the deleted project.
    final workItemsSnapshot = await _tryGet(
      _firestore
          .collection('users')
          .doc(uid)
          .collection('workItems')
          .where('projectId', isEqualTo: projectId),
    );
    if (workItemsSnapshot != null) {
      for (final doc in workItemsSnapshot.docs) {
        batch.update(doc.reference, {'projectId': FieldValue.delete()});
      }
    }

    // The project itself is always deleted, even if the cleanup reads failed.
    batch.delete(projectRef);

    // Not awaited on purpose: offline, the server acknowledgement only comes
    // later, and waiting for it would freeze the UI.
    unawaited(
      batch.commit().catchError((Object error) {
        debugPrint('Error deleting project and cleaning up: $error');
      }),
    );
  }
}