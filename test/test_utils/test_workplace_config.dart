import 'package:dio/dio.dart';
import 'package:twake_drive_picker/src/data/workplace_config.dart';

/// Dio shared by every object under test; tests swap its adapter.
final Dio testDio = Dio();

/// Config handed to the objects under test (http allowed, like debug builds).
WorkplaceConfig get testConfig =>
    WorkplaceConfig(dio: testDio, requireHttps: false);
