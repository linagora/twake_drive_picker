import 'package:flutter_test/flutter_test.dart';
import 'package:twake_drive_picker/src/data/datasource/workplace_datasource.dart';
import 'package:twake_drive_picker/src/data/datasource/workplace_drive_datasource.dart';
import 'package:twake_drive_picker/src/data/datasource_impl/workplace_datasource_impl.dart';
import 'package:twake_drive_picker/src/data/datasource_impl/workplace_request_executor.dart';
import 'package:twake_drive_picker/src/data/repository_impl/workplace_repository_impl.dart';
import 'package:twake_drive_picker/src/entity/drive_uploaded_file.dart';
import 'package:twake_drive_picker/src/entity/workplace_access_mode.dart';
import 'package:twake_drive_picker/src/entity/workplace_action_config.dart';
import 'package:twake_drive_picker/src/entity/workplace_intent.dart';
import 'package:twake_drive_picker/src/entity/workplace_intent_config.dart';
import 'package:twake_drive_picker/src/entity/workplace_theme.dart';
import 'package:twake_drive_picker/src/entity/workplace_upload_file_spec.dart';
import 'package:twake_drive_picker/src/entity/workplace_upload_source.dart';
import 'package:twake_drive_picker/src/entity/workplace_upload_transfer.dart';

import '../test_utils/test_workplace_config.dart';

class _StubUploadSource implements WorkplaceUploadSource {
  const _StubUploadSource();

  @override
  Object? get requestData => 'bytes';

  @override
  Map<String, dynamic> get dioExtra => const {};
}

/// Records the arguments of the last upload.
class _RecordingDriveDataSource implements WorkplaceDriveDataSource {
  WorkplaceRequestContext? context;
  WorkplaceUploadFileSpec? spec;
  WorkplaceUploadTransfer? transfer;

  @override
  Future<DriveUploadedFile> uploadFile({
    required WorkplaceRequestContext context,
    required WorkplaceUploadFileSpec spec,
    WorkplaceUploadTransfer transfer = const WorkplaceUploadTransfer(),
  }) async {
    this.context = context;
    this.spec = spec;
    this.transfer = transfer;
    return const DriveUploadedFile(fileId: 'file-1', name: 'report.pdf');
  }

  @override
  Future<Uri> createShareLink({
    required WorkplaceRequestContext context,
    required String fileId,
  }) => throw UnimplementedError();
}

class _RecordingDataSource implements WorkplaceDataSource {
  Uri? platformUrl;
  WorkplaceAccessMode? accessMode;
  WorkplaceIntentConfig? config;
  String? oidcIdToken;

  @override
  Future<WorkplaceIntent> createIntent({
    required Uri platformUrl,
    required WorkplaceAccessMode accessMode,
    required WorkplaceIntentConfig config,
  }) async {
    this.platformUrl = platformUrl;
    this.accessMode = accessMode;
    this.config = config;
    return WorkplaceIntent(
      intentId: 'intent-1',
      intentUrl: Uri.parse('https://drive.example.com/pick'),
    );
  }

  @override
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken) async {
    this.platformUrl = platformUrl;
    this.oidcIdToken = oidcIdToken;
    return 'access-token';
  }
}

class _ShareLinkDriveDataSource implements WorkplaceDriveDataSource {
  WorkplaceRequestContext? context;
  String? fileId;

  @override
  Future<Uri> createShareLink({
    required WorkplaceRequestContext context,
    required String fileId,
  }) async {
    this.context = context;
    this.fileId = fileId;
    return Uri.parse('https://drive.example.com/public?sharecode=abc');
  }

  @override
  Future<DriveUploadedFile> uploadFile({
    required WorkplaceRequestContext context,
    required WorkplaceUploadFileSpec spec,
    WorkplaceUploadTransfer transfer = const WorkplaceUploadTransfer(),
  }) => throw UnimplementedError();
}

void main() {
  group('WorkplaceRepositoryImpl::createIntent::', () {
    test('delegates to the datasource and returns its intent', () async {
      final dataSource = _RecordingDataSource();
      final platformUrl = Uri.parse('https://platform.example.com');
      const accessMode = BearerTokenAccessMode('token');
      const config = WorkplaceIntentConfig(
        addAsLink: WorkplaceActionConfig(label: 'Link'),
        theme: WorkplaceTheme.dark,
      );

      final intent =
          await WorkplaceRepositoryImpl(
            dataSource,
            _ShareLinkDriveDataSource(),
          ).createIntent(
            platformUrl: platformUrl,
            accessMode: accessMode,
            config: config,
          );

      expect(intent.intentId, 'intent-1');
      expect(dataSource.platformUrl, platformUrl);
      expect(dataSource.accessMode, same(accessMode));
      expect(dataSource.config, config);
    });
  });

  group('WorkplaceRepositoryImpl::exchangeToken::', () {
    test('delegates to the datasource and returns the access token', () async {
      final dataSource = _RecordingDataSource();
      final platformUrl = Uri.parse('https://platform.example.com');

      final token = await WorkplaceRepositoryImpl(
        dataSource,
        _ShareLinkDriveDataSource(),
      ).exchangeToken(platformUrl, 'oidc-token');

      expect(token, 'access-token');
      expect(dataSource.platformUrl, platformUrl);
      expect(dataSource.oidcIdToken, 'oidc-token');
    });
  });

  group('WorkplaceRepositoryImpl::createShareLink::', () {
    test('delegates to the drive datasource', () async {
      final driveDataSource = _ShareLinkDriveDataSource();
      final context = WorkplaceRequestContext(
        platformUrl: Uri.parse('https://platform.example.com'),
        accessMode: const BridgeAccessMode(),
      );

      final link = await WorkplaceRepositoryImpl(
        _RecordingDataSource(),
        driveDataSource,
      ).createShareLink(context: context, fileId: 'file-9');

      expect(link.queryParameters['sharecode'], 'abc');
      expect(driveDataSource.context, same(context));
      expect(driveDataSource.fileId, 'file-9');
    });
  });

  group('WorkplaceRepositoryImpl::uploadFile::', () {
    test(
      'forwards the context, spec and transfer to the drive datasource',
      () async {
        final dataSource = _RecordingDriveDataSource();
        final context = WorkplaceRequestContext(
          platformUrl: Uri.parse('https://platform.example.com'),
          accessMode: const BearerTokenAccessMode('test-token'),
        );
        const spec = WorkplaceUploadFileSpec(
          fileName: 'report.pdf',
          mimeType: 'application/pdf',
          fileSize: 1234,
          source: _StubUploadSource(),
        );
        const transfer = WorkplaceUploadTransfer(
          timeout: Duration(minutes: 30),
        );

        final result = await WorkplaceRepositoryImpl(
          WorkplaceDataSourceImpl(config: testConfig),
          dataSource,
        ).uploadFile(context: context, spec: spec, transfer: transfer);

        expect(dataSource.context, same(context));
        expect(dataSource.spec, same(spec));
        expect(dataSource.transfer, same(transfer));
        expect(result.fileId, equals('file-1'));
      },
    );
  });
}
