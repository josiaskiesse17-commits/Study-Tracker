import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../courses/presentation/providers/course_controller.dart';

class ProjectCoursesPage extends ConsumerStatefulWidget {
  final String projectId;
  final String projectName;

  const ProjectCoursesPage({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  ConsumerState<ProjectCoursesPage> createState() =>
      _ProjectCoursesPageState();
}

class _ProjectCoursesPageState
    extends ConsumerState<ProjectCoursesPage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  Set<String> _linkedCourseIds = {};
  bool _isLoadingLinks = true;

  @override
  void initState() {
    super.initState();
    _loadLinkedCourses();
  }

  Future<void> _loadLinkedCourses() async {
    try {
      final rows = await _supabase
          .from('project_courses')
          .select('course_id')
          .eq('project_id', widget.projectId);

      if (!mounted) return;

      setState(() {
        _linkedCourseIds = rows
            .map<String>(
              (row) => row['course_id'] as String,
            )
            .toSet();
        _isLoadingLinks = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingLinks = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load project courses: $e',
          ),
        ),
      );
    }
  }

  Future<void> _addCourse(String courseId) async {
    try {
      await _supabase.from('project_courses').insert({
        'project_id': widget.projectId,
        'course_id': courseId,
      });

      if (!mounted) return;

      setState(() {
        _linkedCourseIds = {
          ..._linkedCourseIds,
          courseId,
        };
      });

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add course: $e',
          ),
        ),
      );
    }
  }

  Future<void> _removeCourse(String courseId) async {
    try {
      await _supabase
          .from('project_courses')
          .delete()
          .eq('project_id', widget.projectId)
          .eq('course_id', courseId);

      if (!mounted) return;

      setState(() {
        final updated = Set<String>.from(_linkedCourseIds);
        updated.remove(courseId);
        _linkedCourseIds = updated;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to remove course: $e',
          ),
        ),
      );
    }
  }

  void _showAddCourseSheet(List courses) {
    final availableCourses = courses
        .where(
          (course) => !_linkedCourseIds.contains(course.id),
        )
        .toList();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        if (availableCourses.isEmpty) {
          return const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'All your courses are already linked to this project.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              24,
            ),
            children: [
              Text(
                'Add course',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              ...availableCourses.map(
                (course) => Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.school_rounded,
                    ),
                    title: Text(
                      course.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      '${course.progress.toStringAsFixed(0)}% progress',
                    ),
                    trailing: const Icon(
                      Icons.add_rounded,
                    ),
                    onTap: () => _addCourse(course.id),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(courseControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Courses',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: coursesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load courses.\n\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (courses) {
          if (_isLoadingLinks) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final linkedCourses = courses
              .where(
                (course) =>
                    _linkedCourseIds.contains(course.id),
              )
              .toList();

          if (linkedCourses.isEmpty) {
            return _EmptyState(
              projectName: widget.projectName,
              onAddCourse: () {
                _showAddCourseSheet(courses);
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(courseControllerProvider.notifier)
                  .refreshCourses();

              await _loadLinkedCourses();
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  widget.projectName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Courses associated with this project',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                ...linkedCourses.map(
                  (course) => Card(
                    margin: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.school_rounded,
                      ),
                      title: Text(
                        course.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(
                          top: 6,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${course.progress.toStringAsFixed(0)}% progress',
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: (course.progress / 100)
                                  .clamp(0.0, 1.0),
                            ),
                          ],
                        ),
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        tooltip: 'Remove course',
                        icon: const Icon(
                          Icons.link_off_rounded,
                        ),
                        onPressed: () {
                          _removeCourse(course.id);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: coursesAsync.when(
        data: (courses) => FloatingActionButton.extended(
          onPressed: () {
            _showAddCourseSheet(courses);
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Course'),
        ),
        loading: () => null,
        error: (error, stackTrace) => null,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String projectName;
  final VoidCallback onAddCourse;

  const _EmptyState({
    required this.projectName,
    required this.onAddCourse,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            const Text(
              'No courses linked',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Link one of your courses to $projectName.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAddCourse,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Course'),
            ),
          ],
        ),
      ),
    );
  }
}