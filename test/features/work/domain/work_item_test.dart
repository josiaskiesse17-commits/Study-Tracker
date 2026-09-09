import 'package:flutter_test/flutter_test.dart';

import 'package:study_tracker/features/work/domain/entities/task.dart';

void main() {
  final workItem = WorkItem(
    id: 'work-1',
    userId: 'user-1',
    courseId: 'course-1',
    projectId: 'project-1',
    title: 'Complete Dart exercise',
    description: 'Finish the exercise',
    type: 'exercise',
    status: 'pending',
    priority: 'medium',
    dueDate: DateTime(2026, 9, 15),
    createdAt: DateTime(2026, 9, 1),
  );

  test('copyWith updates the title', () {
    final updated = workItem.copyWith(
      title: 'Complete Flutter exercise',
    );

    expect(updated.title, 'Complete Flutter exercise');
    expect(updated.id, workItem.id);
    expect(updated.courseId, workItem.courseId);
    expect(updated.projectId, workItem.projectId);
  });

  test('copyWith updates status and priority', () {
    final updated = workItem.copyWith(
      status: 'in_progress',
      priority: 'high',
    );

    expect(updated.status, 'in_progress');
    expect(updated.priority, 'high');
    expect(updated.title, workItem.title);
  });

  test('copyWith updates project and course', () {
    final updated = workItem.copyWith(
      courseId: 'course-2',
      projectId: 'project-2',
    );

    expect(updated.courseId, 'course-2');
    expect(updated.projectId, 'project-2');
    expect(updated.title, workItem.title);
  });

  test('copyWith updates type and due date', () {
    final newDueDate = DateTime(2026, 9, 20);

    final updated = workItem.copyWith(
      type: 'assignment',
      dueDate: newDueDate,
    );

    expect(updated.type, 'assignment');
    expect(updated.dueDate, newDueDate);
    expect(updated.title, workItem.title);
  });
}
