import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_controller.dart';
import '../../domain/repositories/linked_course_repository.dart';
import 'linked_course_provider.dart';

final linkedCourseControllerProvider =
    AsyncNotifierProvider<LinkedCourseController, Set<String>>(
  LinkedCourseController.new,
);

class LinkedCourseController extends AsyncNotifier<Set<String>> {
  LinkedCourseRepository get _repository => ref.read(linkedCourseRepositoryProvider);

  @override
  Future<Set<String>> build() async {
    // Watch the current user ID so the list reloads when the logged-in user changes
    ref.watch(authControllerProvider.select((s) => s.user?.id));

    // Return empty initially; loadLinkedCourses will be called with projectId
    return {};
  }

  Future<void> loadLinkedCourses(String projectId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _repository.getLinkedCourseIds(projectId),
    );
  }

  Future<void> refreshLinkedCourses(String projectId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _repository.getLinkedCourseIds(projectId),
    );
  }

  Future<void> linkCourse(String projectId, String courseId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repository.linkCourse(projectId, courseId);

      return _repository.getLinkedCourseIds(projectId);
    });
  }

  Future<void> unlinkCourse(String projectId, String courseId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repository.unlinkCourse(projectId, courseId);

      return _repository.getLinkedCourseIds(projectId);
    });
  }
}