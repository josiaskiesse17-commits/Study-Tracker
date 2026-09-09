import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:study_tracker/core/theme/theme_provider.dart';

void main() {
  test('theme mode notifier starts with system mode', () {
    expect(
      themeModeNotifier.value,
      ThemeMode.system,
    );
  });

  test('theme mode notifier can switch to dark mode', () {
    themeModeNotifier.value = ThemeMode.dark;

    expect(
      themeModeNotifier.value,
      ThemeMode.dark,
    );

    themeModeNotifier.value = ThemeMode.system;
  });

  test('theme mode notifier can switch to light mode', () {
    themeModeNotifier.value = ThemeMode.light;

    expect(
      themeModeNotifier.value,
      ThemeMode.light,
    );

    themeModeNotifier.value = ThemeMode.system;
  });
}
