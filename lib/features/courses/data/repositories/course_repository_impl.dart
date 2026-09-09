import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/network_exceptions.dart';
import '../../../../core/storage/app_database.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/course_local_datasource.dart';
import '../datasources/course_remote_datasource.dart';
import '../models/course_model.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource remoteDataSource;
  final CourseLocalDataSource localDataSource;
  final AppDatabase database;
  final SupabaseClient supabase;

  CourseRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.database,
    required this.supabase,
  });

  @override
  Future<List<Course>> getCourses() async {
    final userId = _getCurrentUserId();

    final connectivity = await Connectivity().checkConnectivity();

    final hasConnection = connectivity.any(
      (result) => result != ConnectivityResult.none,
    );

    if (!hasConnection) {
      return localDataSource.getCourses(userId);
    }

    try {
      final courses = await remoteDataSource.getCourses();

      await localDataSource.saveCourses(courses);

      return courses;
    } on NetworkException {
      final cachedCourses =
          await localDataSource.getCourses(userId);

      if (cachedCourses.isNotEmpty) {
        return cachedCourses;
      }

      rethrow;
    }
  }

  @override
  Future<List<Course>> getCachedCourses() {
    final userId = _getCurrentUserId();

    return localDataSource.getCourses(userId);
  }

  @override
  Future<Course> createCourse({
    required String name,
    String? description,
    double progress = 0,
  }) async {
    final userId = _getCurrentUserId();

    final connectivity = await Connectivity().checkConnectivity();

    final hasConnection = connectivity.any(
      (result) => result != ConnectivityResult.none,
    );

    if (!hasConnection) {
      throw const NetworkException(
        'You need an internet connection to create a course.',
      );
    }

    final course = await remoteDataSource.createCourse(
      userId: userId,
      name: name,
      description: description,
      progress: progress,
    );

    await localDataSource.saveCourse(course);

    return course;
  }

  @override
  Future<void> updateCourse({
    required String courseId,
    required String name,
    String? description,
    required double progress,
  }) async {
    final connectivity = await Connectivity().checkConnectivity();

    final hasConnection = connectivity.any(
      (result) => result != ConnectivityResult.none,
    );

    if (!hasConnection) {
      throw const NetworkException(
        'You need an internet connection to update a course.',
      );
    }

    await remoteDataSource.updateCourse(
      courseId: courseId,
      name: name,
      description: description,
      progress: progress,
    );

    final userId = _getCurrentUserId();

    final cachedCourses =
        await localDataSource.getCourses(userId);

    final existingCourse = cachedCourses.firstWhere(
      (course) => course.id == courseId,
      orElse: () => throw const NetworkException(
        'Course was not found in local storage.',
      ),
    );

    final updatedCourse = CourseModel(
      id: existingCourse.id,
      userId: existingCourse.userId,
      name: name,
      description: description,
      progress: progress,
      createdAt: existingCourse.createdAt,
    );

    await localDataSource.updateCourse(updatedCourse);
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    final connectivity = await Connectivity().checkConnectivity();

    final hasConnection = connectivity.any(
      (result) => result != ConnectivityResult.none,
    );

    if (!hasConnection) {
      throw const NetworkException(
        'You need an internet connection to delete a course.',
      );
    }

    await remoteDataSource.deleteCourse(courseId);

    await localDataSource.deleteCourse(courseId);
  }

  String _getCurrentUserId() {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw const NetworkException(
        'You must be logged in to access courses.',
      );
    }

    return user.id;
  }
}