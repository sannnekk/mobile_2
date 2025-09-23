import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:mobile_2/core/api/api_client.dart';
import 'package:mobile_2/core/api/api_response.dart';
import 'package:mobile_2/core/entities/media.dart';

/// Service for media related operations
class MediaService {
  final ApiClient _client;
  MediaService({ApiClient? client}) : _client = client ?? ApiClient();

  /// Upload a single image as bytes. Only jpeg/jpg/png are supported.
  ///
  /// Returns the first MediaEntity from the response array.
  Future<ApiResponse<MediaEntity>> uploadImageBytes(
    Uint8List bytes, {
    required String filename,
  }) async {
    final ext = _extractExtension(filename);
    if (!_isSupported(ext)) {
      return ApiErrorResponse(
        'Этот тип файлов не поддерживается. Поддерживаются только JPEG и PNG.',
      );
    }

    final formData = FormData.fromMap({
      // Many backends expect "files" as an array; we send one item
      'files': [MultipartFile.fromBytes(bytes, filename: filename)],
    });

    final resp = await _client.post<MediaEntity>(
      path: '/media',
      body: formData,
      fromJson: (json) =>
          MediaEntity.fromJson((json as Map).cast<String, dynamic>()),
      isList: true,
    );

    if (resp is ApiListResponse<MediaEntity>) {
      if (resp.data.isEmpty) {
        return ApiErrorResponse('Сервер вернул пустой ответ');
      }
      return ApiSingleResponse<MediaEntity>(resp.data.first);
    }
    if (resp is ApiSingleResponse<MediaEntity>) {
      // Unexpected but handle gracefully
      return resp;
    }
    return resp;
  }

  String _extractExtension(String filename) {
    final dot = filename.lastIndexOf('.');
    if (dot == -1 || dot == filename.length - 1) return '';
    return filename.substring(dot + 1).toLowerCase();
  }

  bool _isSupported(String ext) =>
      ext == 'jpeg' || ext == 'jpg' || ext == 'png';
}
