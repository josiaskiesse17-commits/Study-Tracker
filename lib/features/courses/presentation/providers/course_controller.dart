import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/course.dart';
import '../../domain/usecases/get_courses.dart';
import 'course_provider.dart';

class CourseController extends AsyncNotifier<List<Course>> {
  GetCourses get _getCourses {
    return GetCourses(
      ref.read(courseRepositoryProvider),
    );
  }

  @override
  Future<List<Course>> build() async {
    return _getCourses();
  }

  Future<void> refreshCourses() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _getCourses(),
    );
  }

  Future<void> createCourse({
    required String name,
    String? description,
    double progress = 0,
  }) async {
    final repository = ref.read(courseRepositoryProvider);

    await repository.createCourse(
      name: name,
      description: description,
      progress: progress,
    );

    await refreshCourses();
  }

  Future<void> updateCourse({
    required String courseId,
    required String name,
    String? description,
    required double progress,
  }) async {
    final repository = ref.read(courseRepositoryProvider);

    await repository.updateCourse(
      courseId: courseId,
      name: name,
      description: description,
      progress: progress,
    );

    await refreshCourses();
  }

  Future<void> deleteCourse(String courseId) async {
    final repository = ref.read(courseRepositoryProvider);

    await repository.deleteCourse(courseId);

    await refreshCourses();
  }
}

final courseControllerProvider =
    AsyncNotifierProvider<CourseController, List<Course>>(
  CourseController.new,
);