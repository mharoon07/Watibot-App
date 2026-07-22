import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:dio/dio.dart';
import 'package:watibot/core/services/api_service.dart';

import 'package:watibot/modules/media_library/models/media_item_model.dart';


class MediaLibraryRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<Map<String, dynamic>> getMediaItems({
    int page = 1,
    int limit = 100,
    String search = '',
    String type = 'ALL',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search.trim().isNotEmpty) 'search': search.trim(),
        if (type != 'ALL') 'type': type.toLowerCase(),
      };

      dynamic data;
      try {
        final response = await _apiService.get('/media-library', queryParameters: queryParams);
        data = response.data;
      } catch (e) {
        if (e is ApiException && (e.statusCode == 404 || e.message.contains('404'))) {
          final response = await _apiService.get('/media', queryParameters: queryParams);
          data = response.data;
        } else {
          rethrow;
        }
      }


      List<dynamic> rawList = [];
      int total = 0;

      if (data is List) {
        rawList = data;
        total = data.length;
      } else if (data is Map) {
        if (data['data'] is List) {
          rawList = data['data'];
        } else if (data['media_items'] is List) {
          rawList = data['media_items'];
        }
        total = (data['total'] is int) ? data['total'] : rawList.length;
      }

      final List<MediaItemModel> items = rawList
          .whereType<Map>()
          .map((json) => MediaItemModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      return {
        'items': items,
        'total': total,
        'count': items.length,
      };
    } catch (e) {
      rethrow;
    }
  }


  Future<String> uploadFile(String filePath, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _apiService.post('/media', data: formData);
      final data = response.data;
      if (data is Map && (data['url'] != null || data['media_url'] != null)) {
        return (data['url'] ?? data['media_url']).toString();
      }

      final msg = ApiService.extractErrorMessage(data, 'File upload failed');
      throw ApiException(message: msg);
    } catch (e) {
      rethrow;
    }
  }

  Future<MediaItemModel> addMediaItem({
    required String name,
    required String url,
    required String type,
  }) async {

    try {
      final response = await _apiService.post('/media-library', data: {
        'name': name,
        'url': url,
        'type': type,
      });

      final data = response.data;
      if (data is Map && (data['data'] != null || data['media_item'] != null)) {
        final raw = data['data'] ?? data['media_item'];
        if (raw is Map) {
          return MediaItemModel.fromJson(Map<String, dynamic>.from(raw));
        }
      }

      final msg = ApiService.extractErrorMessage(data, 'Failed to add media item');
      throw ApiException(message: msg);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteMediaItem(String id) async {
    try {
      final response = await _apiService.get('/media-library/$id');
      final data = response.data;
      return response.statusCode == 200 || (data is Map && data['success'] == true);
    } catch (e) {
      rethrow;
    }
  }

}
