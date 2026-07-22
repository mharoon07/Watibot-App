import 'package:get/get.dart';
import 'package:watibot/core/services/api_service.dart';
import 'package:watibot/modules/audience/models/audience_model.dart';

class AudienceRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<Map<String, dynamic>> getAudienceData() async {
    try {
      final response = await _apiService.get('/audience');
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final summary = data['audience'] != null
            ? AudienceSummaryModel.fromJson(data['audience'] as Map<String, dynamic>)
            : null;

        final segments = (data['segments'] as List<dynamic>?)
                ?.map((e) => AudienceSegmentModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];

        return {
          'success': true,
          'audience': summary,
          'segments': segments,
        };
      }
      return {'success': false, 'segments': <AudienceSegmentModel>[]};
    } catch (e) {
      return {'success': false, 'error': ApiService.extractErrorMessage(e, 'Failed to fetch audience data'), 'segments': <AudienceSegmentModel>[]};
    }
  }

  Future<Map<String, dynamic>> createTag({
    required String name,
    String color = '#10B981',
    String category = 'General',
  }) async {
    try {
      final payload = {
        'name': name.trim(),
        'color': color,
        'category': category,
      };

      final response = await _apiService.post('/tags', data: payload);
      final data = response.data;

      if (data is Map<String, dynamic> && data['tag'] != null) {
        return {'success': true, 'segment': AudienceSegmentModel.fromJson(data['tag'])};
      }
      return {'success': true, 'message': 'Tag created successfully'};
    } catch (e) {
      return {'success': false, 'error': ApiService.extractErrorMessage(e, 'Failed to create audience tag')};
    }
  }

  Future<Map<String, dynamic>> deleteTag(String tagId) async {
    try {
      final response = await _apiService.delete('/tags/$tagId');
      final data = response.data;
      return {'success': data['success'] ?? true};
    } catch (e) {
      return {'success': false, 'error': ApiService.extractErrorMessage(e, 'Failed to delete tag')};
    }
  }
}
