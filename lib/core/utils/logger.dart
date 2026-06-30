import 'dart:developer' as developer;

import 'package:logging/logging.dart';

/// Thin wrapper around the `logging` package so the rest of the app depends on
/// a single, swappable logging surface.
class AppLogger {
  AppLogger._();

  static final Logger _root = Logger('EyeGuard');
  static bool _initialised = false;

  /// Wire up log emission. Call once during bootstrap.
  static void init({Level level = Level.INFO}) {
    if (_initialised) return;
    _initialised = true;
    Logger.root.level = level;
    Logger.root.onRecord.listen((LogRecord record) {
      developer.log(
        record.message,
        time: record.time,
        level: record.level.value,
        name: record.loggerName,
        error: record.error,
        stackTrace: record.stackTrace,
      );
    });
  }

  static void info(String message) => _root.info(message);

  static void warning(String message) => _root.warning(message);

  static void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _root.severe(message, error, stackTrace);

  static void debug(String message) => _root.fine(message);
}
