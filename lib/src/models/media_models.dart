import 'package:meta/meta.dart';

@immutable
class MediaData {
  final String mimeType;
  final String base64Data;
  final String? fileName;
  final int? fileSize;

  const MediaData({
    required this.mimeType,
    required this.base64Data,
    this.fileName,
    this.fileSize,
  });

  factory MediaData.fromJson(Map<String, dynamic> json) {
    return MediaData(
      mimeType: json['mimetype'] as String? ?? json['mimeType'] as String? ?? 'application/octet-stream',
      base64Data: json['data'] as String? ?? json['base64'] as String? ?? '',
      fileName: json['filename'] as String? ?? json['fileName'] as String?,
      fileSize: json['size'] as int? ?? json['fileSize'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'mimeType': mimeType,
        'base64Data': base64Data,
        'fileName': fileName,
        'fileSize': fileSize,
      };
}
