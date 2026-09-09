import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:study_tracker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app starts on the login screen', (tester) async {
    app.main();

    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Welcome back to StudyTrack'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
  });

  testWidgets('login form validates required fields', (tester) async {
    app.main();

    await tester.pumpAndSettle(const Duration(seconds: 3));

    final loginButton = find.widgetWithText(ElevatedButton, 'Login');

    expect(loginButton, findsOneWidget);

    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });
}