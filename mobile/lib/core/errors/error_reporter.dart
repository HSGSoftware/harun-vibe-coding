import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Tiny global error sink. Replace with a real reporter (e.g. Sentry) later.
class ErrorReporter {
  ErrorReporter(this._log);
  final Logger _log;

  void report(Object error, StackTrace? stack, {String? where}) {
    _log.e('err${where == null ? '' : ' @$where'}', error: error, stackTrace: stack);
    if (kDebugMode) {
      FlutterError.presentError(FlutterErrorDetails(exception: error, stack: stack));
    }
  }
}
