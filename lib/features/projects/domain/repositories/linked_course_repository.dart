abstract class LinkedCourseRepository {
  Future<Set<String>> getLinkedCourseIds(String projectId);

  Future<void> linkCourse(String projectId, String courseId);

  Future<void> unlinkCourse(String projectId, String courseId);
}