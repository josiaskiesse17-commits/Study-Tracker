import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:study_tracker/features/projects/data/datasources/project_remote_datasource.dart';
import 'package:study_tracker/features/projects/domain/entities/project.dart';
import 'package:study_tracker/features/projects/presentation/pages/project_details_page.dart';
import 'package:study_tracker/features/projects/presentation/providers/project_provider.dart';
import 'package:study_tracker/l10n/app_localizations.dart';

class FakeProjectRemoteDataSource extends Mock implements ProjectRemoteDataSource {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final project = Project(
    id: 'project-1',
    userId: 'user-1',
    name: 'StudyTrack MVP',
    description: 'Build the StudyTrack application.',
    status: 'in_progress',
    deadline: DateTime(2026, 9, 30),
    createdAt: DateTime(2026, 9, 1),
  );

  late FakeProjectRemoteDataSource remoteDataSource;

  setUp(() {
    remoteDataSource = FakeProjectRemoteDataSource();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        projectRemoteDataSourceProvider.overrideWith((ref) => remoteDataSource),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: ProjectDetailsPage(project: project),
      ),
    );
  }

  testWidgets('displays project name', (tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text('StudyTrack MVP'), findsOneWidget);
  });

  testWidgets('displays project description', (tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(
      find.text('Build the StudyTrack application.'),
      findsOneWidget,
    );
  });

  testWidgets('displays project status', (tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text('In progress'), findsNWidgets(2));
  });

  testWidgets('displays project deadline', (tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text('30/09/2026'), findsOneWidget);
  });

  testWidgets('displays project content options', (tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text('Project content'), findsOneWidget);
    expect(find.text('Milestones'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Courses associated with this project'), findsNWidgets(2));
  });
}