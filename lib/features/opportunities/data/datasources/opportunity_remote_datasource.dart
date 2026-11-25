import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/write_error_reporter.dart';
import '../../domain/entities/opportunity.dart';
import '../models/opportunity_model.dart';

class OpportunityRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _getUid() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('You must be logged in to access opportunities.');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> _opportunitiesCollection(
    String uid,
  ) {
    return _firestore.collection('users').doc(uid).collection('opportunities');
  }

  Future<List<OpportunityModel>> getOpportunities() async {
    final uid = _getUid();
    final snapshot = await _opportunitiesCollection(uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => OpportunityModel.fromFirestore(doc))
        .toList();
  }

  Future<OpportunityModel> getOpportunity(String opportunityId) async {
    final uid = _getUid();
    final doc = await _opportunitiesCollection(uid).doc(opportunityId).get();

    if (!doc.exists) {
      throw Exception('Opportunity not found');
    }

    return OpportunityModel.fromFirestore(doc);
  }

  Future<OpportunityModel> createOpportunity({
    required String name,
    required String type,
    String? description,
    String? organizer,
    String? url,
    DateTime? deadlineOrEventDate,
    String status = 'considering',
    String? eligibility,
    String? requirements,
    String? nextAction,
    DateTime? nextActionDueDate,
    String? notes,
  }) async {
    final uid = _getUid();
    final docRef = _opportunitiesCollection(uid).doc();
    final now = DateTime.now();

    final opportunity = OpportunityModel(
      id: docRef.id,
      userId: uid,
      type: type == 'event'
          ? OpportunityType.event
          : OpportunityType.scholarship,
      name: name,
      description: description,
      organizer: organizer,
      url: url,
      deadlineOrEventDate: deadlineOrEventDate,
      status: OpportunityStatus.fromValue(status),
      eligibility: eligibility,
      requirements: requirements,
      nextAction: nextAction,
      nextActionDueDate: nextActionDueDate,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    // Not awaited on purpose: offline, the server acknowledgement only comes
    // later, and waiting for it would freeze the UI.
    unawaited(
      docRef.set(opportunity.toFirestore()).catchError((Object error) {
        debugPrint('Error creating opportunity: $error');
        reportWriteError(error);
      }),
    );

    return opportunity;
  }

  Future<void> updateOpportunity({
    required String opportunityId,
    required String name,
    required String type,
    String? description,
    String? organizer,
    String? url,
    DateTime? deadlineOrEventDate,
    required String status,
    String? eligibility,
    String? requirements,
    String? nextAction,
    DateTime? nextActionDueDate,
    String? notes,
  }) async {
    final uid = _getUid();
    final now = DateTime.now();

    unawaited(
      _opportunitiesCollection(uid)
          .doc(opportunityId)
          .update({
            'name': name,
            'type': type,
            'description': description,
            'organizer': organizer,
            'url': url,
            'deadlineOrEventDate': _dateToIsoString(deadlineOrEventDate),
            'status': status,
            'eligibility': eligibility,
            'requirements': requirements,
            'nextAction': nextAction,
            'nextActionDueDate': _dateToIsoString(nextActionDueDate),
            'notes': notes,
            'updatedAt': Timestamp.fromDate(now),
          })
          .catchError((Object error) {
            debugPrint('Error updating opportunity: $error');
            reportWriteError(error);
          }),
    );
  }

  Future<void> deleteOpportunity(String opportunityId) async {
    final uid = _getUid();

    unawaited(
      _opportunitiesCollection(uid)
          .doc(opportunityId)
          .delete()
          .catchError((Object error) {
            debugPrint('Error deleting opportunity: $error');
            reportWriteError(error);
          }),
    );
  }

  static String? _dateToIsoString(DateTime? date) {
    if (date == null) return null;
    return date.toIso8601String().split('T').first;
  }
}
