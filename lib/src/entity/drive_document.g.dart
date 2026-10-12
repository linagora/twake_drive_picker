// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drive_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriveDocument _$DriveDocumentFromJson(Map<String, dynamic> json) =>
    DriveDocument(
      id: json['id'] as String,
      name: json['name'] as String,
      size: (json['size'] as num).toInt(),
      mimeType: json['mimeType'] as String?,
      sharingLink: json['sharingLink'] == null
          ? null
          : Uri.parse(json['sharingLink'] as String),
      downloadLink: json['downloadLink'] == null
          ? null
          : Uri.parse(json['downloadLink'] as String),
      thumbnail: json['thumbnail'] == null
          ? null
          : DriveDocumentThumbnail.fromJson(
              json['thumbnail'] as Map<String, dynamic>,
            ),
    );

DriveDocumentThumbnail _$DriveDocumentThumbnailFromJson(
  Map<String, dynamic> json,
) => DriveDocumentThumbnail(
  link: json['link'] == null ? null : Uri.parse(json['link'] as String),
);
