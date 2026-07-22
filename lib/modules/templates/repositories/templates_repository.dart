import 'package:get/get.dart';
import 'package:watibot/core/services/api_service.dart';
import 'package:watibot/modules/templates/models/template_model.dart';

class TemplatesRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<Map<String, dynamic>> getTemplates({
    int page = 1,
    int limit = 100,
    String search = '',
    String category = 'ALL',
    String status = 'ALL',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search.trim().isNotEmpty) 'search': search.trim(),
        if (category != 'ALL') 'category': category,
        if (status != 'ALL') 'status': status,
      };

      final response = await _apiService.get('/templates', queryParameters: queryParams);
      final data = response.data;

      List<dynamic> rawList = [];
      int total = 0;

      if (data is List) {
        rawList = data;
        total = data.length;
      } else if (data is Map) {
        if (data['data'] is List) {
          rawList = data['data'];
        } else if (data['templates'] is List) {
          rawList = data['templates'];
        }
        total = (data['total'] is int) ? data['total'] : rawList.length;
      }

      final List<TemplateModel> templates = rawList
          .whereType<Map>()
          .map((json) => TemplateModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      return {
        'templates': templates,
        'total': total,
        'count': templates.length,
      };
    } catch (e) {
      rethrow;
    }
  }


  Future<TemplateModel> getTemplateById(String templateId) async {
    try {
      final response = await _apiService.get('/templates/$templateId');
      final data = response.data;
      if (data is Map && (data['data'] != null || data['template'] != null)) {
        final raw = data['data'] ?? data['template'];
        if (raw is Map) {
          return TemplateModel.fromJson(Map<String, dynamic>.from(raw));
        }
      }
      final msg = ApiService.extractErrorMessage(data, 'Template not found');
      throw ApiException(message: msg);
    } catch (e) {
      rethrow;
    }
  }

  Future<TemplateModel> createTemplate(Map<String, dynamic> payload) async {
    try {
      final response = await _apiService.post('/templates', data: payload);
      final data = response.data;
      if (data is Map && (data['data'] != null || data['template'] != null || data['id'] != null)) {
        final raw = data['data'] ?? data['template'] ?? data;
        if (raw is Map) {
          return TemplateModel.fromJson(Map<String, dynamic>.from(raw));
        }
      }
      final msg = ApiService.extractErrorMessage(data, 'Failed to create template');
      throw ApiException(message: msg);
    } catch (e) {
      rethrow;
    }
  }


  Future<bool> deleteTemplate(String templateId) async {
    try {
      final response = await _apiService.get('/templates/$templateId'); // or delete
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }
}
