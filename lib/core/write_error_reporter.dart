import 'dart:async';

/// A simple broadcast stream controller for reporting write errors
/// from Firestore data sources to the UI.
class WriteErrorReporter {
  static final _controller = StreamController<String>.broadcast();

  static Stream<String> get stream => _controller.stream;

  static void report(Object error) {
    _controller.add(error.toString());
  }

  static void dispose() {
    _controller.close();
  }
}

/// Top-level function for easy access from data sources.
void reportWriteError(Object error) {
  WriteErrorReporter.report(error);
}