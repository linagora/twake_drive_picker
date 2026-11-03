import 'package:equatable/equatable.dart';

class WorkplaceActionConfig extends Equatable {
  final String? label;
  final num? maxFileSize;
  final num? availableSize;

  /// Whether a folder can be picked for this action. Null keeps Drive's own
  /// default (links allow folders, attachments do not).
  ///
  /// Drive treats this key as legacy and prefers [accept]: it is ignored when
  /// [accept] is set, and the attachment action never accepts folders
  /// whatever its value.
  final bool? allowFolder;

  /// What the action accepts, matched as OR: `file`, `folder` and/or mime
  /// types and patterns such as `image/*`. Null keeps Drive's default
  /// (anything [allowFolder] allows). An empty list accepts nothing. When set,
  /// Drive ignores [allowFolder].
  final List<String>? accept;

  /// Most items that can be picked at once for this action. Drive counts
  /// every selected item, folders included. Null means no limit.
  final num? maxFileCount;

  const WorkplaceActionConfig({
    this.label,
    this.maxFileSize,
    this.availableSize,
    this.allowFolder,
    this.accept,
    this.maxFileCount,
  });

  @override
  List<Object?> get props => [
    label,
    maxFileSize,
    availableSize,
    allowFolder,
    accept,
    maxFileCount,
  ];
}
