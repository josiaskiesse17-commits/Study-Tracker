import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/milestone_model.dart';

class MilestoneRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _getUid() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('You must be logged in to access milestones.');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> _milestonesCollection(
    String uid,
    String projectId,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('projects')
        .doc(projectId)
        .collection('milestones');
  }

  Future<List<MilestoneModel>> getMilestones(
    String projectId,
  ) async {
    final uid = _getUid();
    final snapshot = await _milestonesCollection(uid, projectId)
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => MilestoneModel.fromFirestore(doc))
        .toList();
  }

  Future<MilestoneModel> createMilestone({
    required String projectId,
    required String title,
    String? description,
    String status = 'pending',
    DateTime? dueDate,
  }) async {
    final uid = _getUid();
    final docRef = _milestonesCollection(uid, projectId).doc();

    final milestone = MilestoneModel(
      id: docRef.id,
      projectId: projectId,
      title: title,
      description: description,
      status: status,
      dueDate: dueDate,
      createdAt: DateTime.now(),
    );

    // Not awaited on purpose: offline, the server acknowledgement only comes
    // later, and waiting for it would freeze the UI.
    unawaited(
      docRef.set(milestone.toFirestore()).catchError((Object error) {
        debugPrint('Error creating milestone: $error');
      }),
    );

    return milestone;
  }

  Future<void> updateMilestone({
    required String milestoneId,
    required String projectId,
    required String title,
    String? description,
    required String status,
    DateTime? dueDate,
  }) async {
    final uid = _getUid();

    unawaited(
      _milestonesCollection(uid, projectId).doc(milestoneId).update({
        'title': title,
        'description': description,
        'status': status,
        'dueDate': dueDate?.toIso8601String().split('T').first,
      }).catchError((Object error) {
        debugPrint('Error updating milestone: $error');
      }),
    );
  }

  Future<void> deleteMilestone({
    required String milestoneId,
    required String projectId,
  }) async {
    final uid = _getUid();

    unawaited(
      _milestonesCollection(uid, projectId)
          .doc(milestoneId)
          .delete()
          .catchError((Object error) {
        debugPrint('Error deleting milestone: $error');
      }),
    );
  }
}