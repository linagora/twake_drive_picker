import 'workplace_logger.dart';

/// Names match `package:core` `app_logger.dart` so ported call sites stay the same.
/// Not exported from the package barrel, so it does not clash with `dart:developer` `log`.
void log(String message) => activeWorkplaceLogger.log(message);

void logError(
  String message, {
  Object? exception,
  StackTrace? stackTrace,
  bool webConsoleEnabled = false,
}) => activeWorkplaceLogger.error(
  message,
  exception: exception,
  stackTrace: stackTrace,
);

void logWarning(String message, {bool webConsoleEnabled = false}) =>
    activeWorkplaceLogger.log(message);

void logTrace(
  String message, {
  Map<String, Object?> extras = const {},
  bool webConsoleEnabled = false,
}) => activeWorkplaceLogger.log(message);
