import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../providers/course_controller.dart';

class CoursesPage extends ConsumerWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(courseControllerProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.myCourses,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton.filled(
              onPressed: () {
                _showCourseDialog(context, ref);
              },
              icon: const Icon(Icons.add_rounded),
              tooltip: l10n.createCourse,
            ),
          ),
        ],
      ),
      body: coursesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _ErrorState(
          message: l10n.unableToLoadCourses,
          error: error.toString(),
          onRetry: () {
            ref
                .read(courseControllerProvider.notifier)
                .refreshCourses();
          },
        ),
        data: (courses) {
          if (courses.isEmpty) {
            return RefreshIndicator(
              onRefresh: () {
                return ref
                    .read(courseControllerProvider.notifier)
                    .refreshCourses();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 110),
                  Icon(
                    Icons.school_rounded,
                    size: 72,
                    color: colors.primary,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      l10n.noCoursesYet,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                      ),
                      child: Text(
                        l10n.createFirstCourse,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                    ),
                    child: FilledButton.icon(
                      onPressed: () {
                        _showCourseDialog(context, ref);
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: Text(l10n.createCourse),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () {
              return ref
                  .read(courseControllerProvider.notifier)
                  .refreshCourses();
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                final progress =
                    (course.progress / 100).clamp(0.0, 1.0);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Card(
                    color: colors.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: colors.primaryContainer,
                                  borderRadius:
                                      BorderRadius.circular(15),
                                ),
                                child: Icon(
                                  Icons.school_rounded,
                                  color:
                                      colors.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      course.name,
                                      maxLines: 2,
                                      overflow:
                                          TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight:
                                            FontWeight.w700,
                                      ),
                                    ),
                                    if (course.description !=
                                        null) ...[
                                      const SizedBox(height: 5),
                                      Text(
                                        course.description!,
                                        maxLines: 2,
                                        overflow:
                                            TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: colors
                                              .onSurfaceVariant,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                tooltip: l10n.edit,
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showCourseDialog(
                                      context,
                                      ref,
                                      course: course,
                                    );
                                  }

                                  if (value == 'delete') {
                                    _confirmDeleteCourse(
                                      context,
                                      ref,
                                      course.id,
                                      course.name,
                                    );
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        const Icon(Icons.edit_rounded),
                                        const SizedBox(width: 12),
                                        Text(l10n.edit),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.delete_outline,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(l10n.delete),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.progress,
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${course.progress.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 9),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDeleteCourse(
    BuildContext context,
    WidgetRef ref,
    String courseId,
    String courseName,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteCourse),
          content: Text(
            l10n.deleteCourseConfirmation(courseName),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(courseControllerProvider.notifier)
          .deleteCourse(courseId);
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.failedToDeleteCourse(error.toString()),
          ),
        ),
      );
    }
  }

  void _showCourseDialog(
    BuildContext context,
    WidgetRef ref, {
    dynamic course,
  }) {
    final isEditing = course != null;
    final l10n = AppLocalizations.of(context)!;

    final nameController = TextEditingController(
      text: isEditing ? course.name : '',
    );

    final descriptionController = TextEditingController(
      text: isEditing ? course.description ?? '' : '',
    );

    var progress = isEditing
        ? (course.progress as double)
        : 0.0;

    showDialog(
      context: context,
      builder: (dialogContext) {
        var isSaving = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                isEditing ? l10n.editCourse : l10n.createCourse,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      textCapitalization:
                          TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: l10n.courseName,
                        prefixIcon:
                            const Icon(Icons.school_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      textCapitalization:
                          TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: l10n.description,
                        hintText: l10n.optional,
                        prefixIcon:
                            const Icon(Icons.notes_rounded),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.progress,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${progress.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: progress,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label:
                          '${progress.toStringAsFixed(0)}%',
                      onChanged: (value) {
                        setState(() {
                          progress = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final name =
                              nameController.text.trim();

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.courseNameRequired,
                                ),
                              ),
                            );
                            return;
                          }

                          setState(() {
                            isSaving = true;
                          });

                          try {
                            final description =
                                descriptionController.text
                                    .trim();

                            if (isEditing) {
                              await ref
                                  .read(
                                    courseControllerProvider
                                        .notifier,
                                  )
                                  .updateCourse(
                                    courseId: course.id,
                                    name: name,
                                    description:
                                        description.isEmpty
                                            ? null
                                            : description,
                                    progress: progress,
                                  );
                            } else {
                              await ref
                                  .read(
                                    courseControllerProvider
                                        .notifier,
                                  )
                                  .createCourse(
                                    name: name,
                                    description:
                                        description.isEmpty
                                            ? null
                                            : description,
                                    progress: progress,
                                  );
                            }

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                          } catch (error) {
                            if (!dialogContext.mounted) {
                              return;
                            }

                            setState(() {
                              isSaving = false;
                            });

                            ScaffoldMessenger.of(
                              dialogContext,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.failedToSaveCourse(
                                    error.toString(),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isEditing ? l10n.saveChanges : l10n.create,
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: colors.error,
            ),
            const SizedBox(height: 18),
            Text(
              message,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
