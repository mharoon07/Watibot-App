import 'package:get/get.dart';
import 'package:watibot/core/services/api_service.dart';
import 'package:watibot/modules/campaigns/models/campaign_model.dart';

class CampaignsRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<Map<String, dynamic>> getPaginatedCampaigns({
    int page = 1,
    int limit = 20,
    String search = '',
    String tab = 'all',
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (search.isNotEmpty) 'search': search,
      };

      // Depending on the tab, we can filter by status or type
      if (tab == 'scheduled') queryParams['status'] = 'SCHEDULED';
      if (tab == 'running') queryParams['status'] = 'RUNNING';
      if (tab == 'completed') queryParams['status'] = 'SENT';

      final response = await _apiService.get('/campaigns', queryParameters: queryParams);
      
      final data = response.data;
      if (data != null && data['success'] == true) {
        final List<dynamic> campaignsJson = data['campaigns'] ?? [];
        return {
          'campaigns': campaignsJson.map((json) => CampaignModel.fromJson(json)).toList(),
          'total': data['total'] ?? 0,
          'totalPages': data['total_pages'] ?? 1,
        };
      }
      throw ApiException(message: 'Invalid response format');
    } catch (e) {
      rethrow;
    }
  }

  // Fallback if anyone uses this
  Future<List<CampaignModel>> getCampaigns() async {
    final res = await getPaginatedCampaigns();
    return res['campaigns'] as List<CampaignModel>;
  }
}
