/// Type of opportunity: a scholarship to apply for, or an event to attend.
enum OpportunityType {
  scholarship,
  event;

  String get labelKey {
    switch (this) {
      case OpportunityType.scholarship:
        return 'scholarship';
      case OpportunityType.event:
        return 'event';
    }
  }

  String get iconKey {
    switch (this) {
      case OpportunityType.scholarship:
        return 'school';
      case OpportunityType.event:
        return 'calendar';
    }
  }
}

/// Status of an opportunity. Valid values depend on [OpportunityType].
enum OpportunityStatus {
  considering,
  preparing,
  applied,
  awarded,
  rejected,
  withdrawn,
  registered,
  attended,
  missed,
  cancelled;

  /// Returns the valid statuses for a given [OpportunityType].
  static List<OpportunityStatus> forType(OpportunityType type) {
    switch (type) {
      case OpportunityType.scholarship:
        return [
          OpportunityStatus.considering,
          OpportunityStatus.preparing,
          OpportunityStatus.applied,
          OpportunityStatus.awarded,
          OpportunityStatus.rejected,
          OpportunityStatus.withdrawn,
        ];
      case OpportunityType.event:
        return [
          OpportunityStatus.considering,
          OpportunityStatus.registered,
          OpportunityStatus.attended,
          OpportunityStatus.missed,
          OpportunityStatus.cancelled,
        ];
    }
  }

  String get value {
    return name;
  }

  static OpportunityStatus fromValue(String value) {
    return OpportunityStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OpportunityStatus.considering,
    );
  }
}

/// Represents a scholarship or event that a user wants to track.
class Opportunity {
  final String id;
  final String userId;
  final OpportunityType type;
  final String name;
  final String? description;
  final String? organizer;
  final String? url;
  final DateTime? deadlineOrEventDate;
  final OpportunityStatus status;
  final String? eligibility;
  final String? requirements;
  final String? nextAction;
  final DateTime? nextActionDueDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Opportunity({
    required this.id,
    required this.userId,
    required this.type,
    required this.name,
    this.description,
    this.organizer,
    this.url,
    this.deadlineOrEventDate,
    required this.status,
    this.eligibility,
    this.requirements,
    this.nextAction,
    this.nextActionDueDate,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  /// Returns the date most relevant to this opportunity:
  /// the deadline for scholarships, or the event date for events.
  DateTime? get relevantDate => deadlineOrEventDate;

  /// True when the relevant date has passed and the opportunity is not
  /// in a terminal state.
  bool get isOverdue {
    final relevant = relevantDate;
    if (relevant == null) return false;
    final terminal = [
      OpportunityStatus.awarded,
      OpportunityStatus.rejected,
      OpportunityStatus.withdrawn,
      OpportunityStatus.attended,
      OpportunityStatus.missed,
      OpportunityStatus.cancelled,
    ];
    if (terminal.contains(status)) return false;
    return relevant.isBefore(DateTime.now());
  }

  /// True when a next action is set and not yet completed.
  bool get hasNextAction => nextAction != null && nextAction!.isNotEmpty;

  Opportunity copyWith({
    String? id,
    String? userId,
    OpportunityType? type,
    String? name,
    String? description,
    String? organizer,
    String? url,
    DateTime? deadlineOrEventDate,
    OpportunityStatus? status,
    String? eligibility,
    String? requirements,
    String? nextAction,
    DateTime? nextActionDueDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearUpdatedAt = false,
  }) {
    return Opportunity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description,
      organizer: organizer,
      url: url,
      deadlineOrEventDate: deadlineOrEventDate,
      status: status ?? this.status,
      eligibility: eligibility,
      requirements: requirements,
      nextAction: nextAction,
      nextActionDueDate: nextActionDueDate,
      notes: notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: clearUpdatedAt ? null : (updatedAt ?? this.updatedAt),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Opportunity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          type == other.type &&
          name == other.name &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      type.hashCode ^
      name.hashCode ^
      status.hashCode;

  @override
  String toString() {
    return 'Opportunity(id: $id, type: $type, name: $name, status: $status)';
  }
}
