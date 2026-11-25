import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/opportunity.dart';

class OpportunityModel extends Opportunity {
  const OpportunityModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.name,
    super.description,
    super.organizer,
    super.url,
    super.deadlineOrEventDate,
    required super.status,
    super.eligibility,
    super.requirements,
    super.nextAction,
    super.nextActionDueDate,
    super.notes,
    required super.createdAt,
    super.updatedAt,
  });

  factory OpportunityModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return OpportunityModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      type: _parseOpportunityType(data['type'] as String?),
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      organizer: data['organizer'] as String?,
      url: data['url'] as String?,
      deadlineOrEventDate: _parseDate(data['deadlineOrEventDate']),
      status: OpportunityStatus.fromValue(
        data['status'] as String? ?? 'considering',
      ),
      eligibility: data['eligibility'] as String?,
      requirements: data['requirements'] as String?,
      nextAction: data['nextAction'] as String?,
      nextActionDueDate: _parseDate(data['nextActionDueDate']),
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.name,
      'name': name,
      'description': description,
      'organizer': organizer,
      'url': url,
      'deadlineOrEventDate': _dateToIsoString(deadlineOrEventDate),
      'status': status.name,
      'eligibility': eligibility,
      'requirements': requirements,
      'nextAction': nextAction,
      'nextActionDueDate': _dateToIsoString(nextActionDueDate),
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  static OpportunityType _parseOpportunityType(String? value) {
    switch (value) {
      case 'scholarship':
        return OpportunityType.scholarship;
      case 'event':
        return OpportunityType.event;
      default:
        return OpportunityType.scholarship;
    }
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static String? _dateToIsoString(DateTime? date) {
    if (date == null) return null;
    return date.toIso8601String().split('T').first;
  }
}
