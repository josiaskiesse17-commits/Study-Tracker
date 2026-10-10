import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_tracker/core/write_error_reporter.dart';

final writeErrorReporterProvider = StreamProvider<String>((ref) {
  return WriteErrorReporter.stream;
});