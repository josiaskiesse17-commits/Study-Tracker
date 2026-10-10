import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

String workTypeLabel(BuildContext context, String type) {
  final l10n = AppLocalizations.of(context)!;
  switch (type) {
    case 'homework':
      return l10n.homework;
    case 'assignment':
      return l10n.assignment;
    case 'reading':
      return l10n.reading;
    case 'exercise':
      return l10n.exercise;
    case 'exam':
      return l10n.exam;
    case 'quiz':
      return l10n.quiz;
    case 'practice':
      return l10n.practice;
    default:
      return l10n.other;
  }
}

String workStatusLabel(BuildContext context, String status) {
  final l10n = AppLocalizations.of(context)!;
  switch (status) {
    case 'in_progress':
      return l10n.inProgress;
    case 'completed':
      return l10n.completed;
    default:
      return l10n.pending;
  }
}

String workPriorityLabel(BuildContext context, String priority) {
  final l10n = AppLocalizations.of(context)!;
  switch (priority) {
    case 'high':
      return l10n.highPriority;
    case 'low':
      return l10n.lowPriority;
    default:
      return l10n.mediumPriority;
  }
}

String projectStatusLabel(BuildContext context, String status) {
  final l10n = AppLocalizations.of(context)!;
  switch (status) {
    case 'in_progress':
      return l10n.inProgress;
    case 'completed':
      return l10n.completed;
    case 'planning':
      return l10n.planning;
    default:
      return status;
  }
}