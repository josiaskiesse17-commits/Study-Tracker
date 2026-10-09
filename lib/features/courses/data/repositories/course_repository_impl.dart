import '../../domain/entities/course.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/course_remote_datasource.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource remoteDataSource;

  CourseRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Course>> getCourses() async {
    return remoteDataSource.getCourses();
  }

  @override
  Future<Course> createCourse({
    required String name,
    String? description,
    double progress = 0,
  }) async {
    return remoteDataSource.createCourse(
      name: name,
      description: description,
      progress: progress,
    );
  }

  @override
  Future<void> updateCourse({
    required String courseId,
    required String name,
    String? description,
    required double progress,
  }) async {
    await remoteDataSource.updateCourse(
      courseId: courseId,
      name: name,
      description: description,
      progress: progress,
    );
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    await remoteDataSource.deleteCourse(courseId);
  }
}