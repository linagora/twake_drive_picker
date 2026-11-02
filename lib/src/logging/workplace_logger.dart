/// Receives the log lines of the SDK; the host app implements it to forward
/// them to its own logger.
abstract interface class WorkplaceLogger {
  void log(String message);

  void error(String message, {Object? exception, StackTrace? stackTrace});
}

/// Default logger: drops every line.
class NoopWorkplaceLogger implements WorkplaceLogger {
  const NoopWorkplaceLogger();

  @override
  void log(String message) {}

  @override
  void error(String message, {Object? exception, StackTrace? stackTrace}) {}
}

/// Logger used by protocol code that upstream calls through `package:core`.
/// The host app can replace it to forward lines into its own logger.
WorkplaceLogger activeWorkplaceLogger = const NoopWorkplaceLogger();
