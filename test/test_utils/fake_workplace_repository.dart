import 'package:twake_drive_picker/src/domain/repository/workplace_repository.dart';
import 'package:twake_drive_picker/src/entity/drive_uploaded_file.dart';
import 'package:twake_drive_picker/src/entity/workplace_access_mode.dart';
import 'package:twake_drive_picker/src/entity/workplace_intent.dart';
import 'package:twake_drive_picker/src/entity/workplace_intent_config.dart';
import 'package:twake_drive_picker/src/entity/workplace_request_context.dart';
import 'package:twake_drive_picker/src/entity/workplace_upload_file_spec.dart';
import 'package:twake_drive_picker/src/entity/workplace_upload_transfer.dart';

/// Repository whose intent and token calls are scripted by the test.
class FakeWorkplaceRepository implements WorkplaceRepository {
  Future<WorkplaceIntent> Function()? onCreateIntent;
  Future<String> Function()? onExchangeToken;

  Uri? lastPlatformUrl;
  WorkplaceAccessMode? lastAccessMode;
  WorkplaceIntentConfig? lastConfig;
  String? lastOidcIdToken;

  @override
  Future<WorkplaceIntent> createIntent({
    required Uri platformUrl,
    required WorkplaceAccessMode accessMode,
    required WorkplaceIntentConfig config,
  }) {
    lastPlatformUrl = platformUrl;
    lastAccessMode = accessMode;
    lastConfig = config;
    return onCreateIntent!();
  }

  @override
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken) {
    lastPlatformUrl = platformUrl;
    lastOidcIdToken = oidcIdToken;
    return onExchangeToken!();
  }

  @override
  Future<DriveUploadedFile> uploadFile({
    required WorkplaceRequestContext context,
    required WorkplaceUploadFileSpec spec,
    WorkplaceUploadTransfer transfer = const WorkplaceUploadTransfer(),
  }) => throw UnimplementedError();

  @override
  Future<Uri> createShareLink({
    required WorkplaceRequestContext context,
    required String fileId,
  }) => throw UnimplementedError();
}
