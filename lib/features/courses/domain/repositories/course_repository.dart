import '../entities/course.dart';

abstract class CourseRepository {
  Future<List<Course>> getCourses();

  Future<List<Course>> getCachedCourses();

  Future<Course> createCourse({
    required String name,
    String? description,
    double progress = 0,
  });

  Future<void> updateCourse({
    required String courseId,
    required String name,
    String? description,
    required double progress,
  });

  Future<void> deleteCourse(String courseId);
}