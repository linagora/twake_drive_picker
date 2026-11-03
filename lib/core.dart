/// UI-free core of the Drive picker: datasource, repository, interactors,
/// `CozyBridge`, intent request / state, `DrivePickOutcome`, origin validator
/// and message parsing.
///
/// Imports no widget, WebView or browser library, so it can be used headless
/// (a host that opens the Drive intent itself) and from non-Flutter-UI code.
/// Single sign-on stays the host app's job: this library only receives a token
/// or a configured `Dio`.
library;

export 'src/bridge/cozy_bridge_transport.dart';
export 'src/data/bridge/cozy_bridge.dart';
export 'src/data/datasource/workplace_datasource.dart';
export 'src/data/datasource/workplace_drive_datasource.dart';
export 'src/data/datasource_impl/workplace_datasource_impl.dart';
export 'src/data/datasource_impl/workplace_drive_datasource_impl.dart';
export 'src/data/datasource_impl/workplace_request_executor.dart';
export 'src/data/repository_impl/workplace_repository_impl.dart';
export 'src/data/transport/workplace_access_mode_runner.dart';
export 'src/data/workplace_config.dart';
export 'src/domain/exceptions/workplace_exceptions.dart';
export 'src/domain/repository/workplace_repository.dart';
export 'src/domain/state/workplace_intent_state.dart';
export 'src/domain/state/workplace_state.dart';
export 'src/domain/usecase/create_drive_intent_call.dart';
export 'src/domain/usecase/create_drive_intent_interactor.dart';
export 'src/domain/usecase/drive_oversize_upload_call.dart';
export 'src/domain/usecase/exchange_drive_token_interactor.dart';
export 'src/domain/usecase/upload_drive_file_interactor.dart';
export 'src/domain/usecase/workplace_call.dart';
export 'src/entity/bridge_policy.dart';
export 'src/entity/drive_document.dart';
export 'src/entity/drive_document_extension.dart';
export 'src/entity/drive_shared_file.dart';
export 'src/entity/drive_uploaded_file.dart';
export 'src/entity/workplace_access_mode.dart';
export 'src/entity/workplace_action_config.dart';
export 'src/entity/workplace_file_picker_tab.dart';
export 'src/entity/workplace_intent.dart';
export 'src/entity/workplace_intent_access_mode.dart';
export 'src/entity/workplace_intent_config.dart';
export 'src/entity/workplace_request_context.dart';
export 'src/entity/workplace_theme.dart';
export 'src/entity/workplace_upload_file_spec.dart';
export 'src/entity/workplace_upload_source.dart';
export 'src/entity/workplace_upload_transfer.dart';
export 'src/logging/workplace_logger.dart';
export 'src/message/workplace_intent_message.dart';
export 'src/model/workplace_enums.dart';
export 'src/model/workplace_exchange_token_request.dart';
export 'src/model/workplace_exchange_token_response.dart';
export 'src/model/workplace_file_response.dart';
export 'src/model/workplace_intent_request.dart';
export 'src/model/workplace_intent_response.dart';
export 'src/model/workplace_permission_request.dart';
export 'src/model/workplace_permission_response.dart';
export 'src/model/workplace_request_body.dart';
export 'src/model/workplace_request_route.dart';
export 'src/model/workplace_request_transfer.dart';
export 'src/picker/drive_origin_validator.dart';
export 'src/picker/drive_pick_outcome.dart';
