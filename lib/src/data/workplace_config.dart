import 'package:dio/dio.dart';

/// Same value as Flutter's `kReleaseMode`, without importing Flutter.
const bool _isReleaseBuild = bool.fromEnvironment('dart.vm.product');

/// HTTP settings of the data layer, injected into the datasources and the
/// request executor instead of being read from globals.
class WorkplaceConfig {
  /// [dio] defaults to a client with 10 s timeouts. [requireHttps] defaults to
  /// true in release builds only, so local http backends work in debug.
  WorkplaceConfig({Dio? dio, bool? requireHttps})
    : dio = dio ?? createWorkplaceDio(),
      requireHttps = requireHttps ?? _isReleaseBuild;

  /// Client used for every request sent with a bearer token.
  final Dio dio;

  /// Whether intent URLs must be served over https.
  final bool requireHttps;
}

/// Default client: short timeouts, since the calls are small JSON exchanges.
Dio createWorkplaceDio() {
  const timeout = Duration(seconds: 10);
  return Dio(
    BaseOptions(
      sendTimeout: timeout,
      receiveTimeout: timeout,
      connectTimeout: timeout,
    ),
  );
}
