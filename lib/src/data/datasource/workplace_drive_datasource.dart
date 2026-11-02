import '../../entity/drive_uploaded_file.dart';
import '../../entity/workplace_request_context.dart';
import '../../entity/workplace_upload_file_spec.dart';
import '../../entity/workplace_upload_transfer.dart';

abstract class WorkplaceDriveDataSource {
  Future<DriveUploadedFile> uploadFile({
    required WorkplaceRequestContext context,
    required WorkplaceUploadFileSpec spec,
    WorkplaceUploadTransfer transfer,
  });

  Future<Uri> createShareLink({
    required WorkplaceRequestContext context,
    required String fileId,
  });
}
