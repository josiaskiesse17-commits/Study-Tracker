import '../../domain/repositories/linked_course_repository.dart';
import '../datasources/linked_course_remote_datasource.dart';

class LinkedCourseRepositoryImpl implements LinkedCourseRepository {
  final LinkedCourseRemoteDataSource remoteDataSource;

  LinkedCourseRepositoryImpl(this.remoteDataSource);

  @override
  Future<Set<String>> getLinkedCourseIds(String projectId) async {
    final linkedCourses = await remoteDataSource.getLinkedCourses(projectId);
    return linkedCourses.map((lc) => lc.courseId).toSet();
  }

  @override
  Future<void> linkCourse(String projectId, String courseId) async {
    await remoteDataSource.linkCourse(projectId, courseId);
  }

  @override
  Future<void> unlinkCourse(String projectId, String courseId) async {
    await remoteDataSource.unlinkCourse(projectId, courseId);
  }
}