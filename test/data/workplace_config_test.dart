import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twake_drive_picker/src/data/workplace_config.dart';

void main() {
  group('WorkplaceConfig', () {
    test('defaults to a Dio with 10 second timeouts', () {
      final config = WorkplaceConfig();

      const timeout = Duration(seconds: 10);
      expect(config.dio.options.connectTimeout, timeout);
      expect(config.dio.options.sendTimeout, timeout);
      expect(config.dio.options.receiveTimeout, timeout);
    });

    test('each default config owns its Dio', () {
      expect(identical(WorkplaceConfig().dio, WorkplaceConfig().dio), isFalse);
    });

    test('uses the injected Dio and https policy', () {
      final dio = Dio();

      final config = WorkplaceConfig(dio: dio, requireHttps: true);

      expect(identical(config.dio, dio), isTrue);
      expect(config.requireHttps, isTrue);
    });

    test('requireHttps defaults to the release-build flag', () {
      expect(
        WorkplaceConfig().requireHttps,
        const bool.fromEnvironment('dart.vm.product'),
      );
    });
  });
}
