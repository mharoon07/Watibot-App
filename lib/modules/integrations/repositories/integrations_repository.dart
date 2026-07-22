import 'package:get/get.dart';
import 'package:watibot/core/services/api_service.dart';
import 'package:watibot/modules/integrations/models/integration_model.dart';

class IntegrationsRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<Map<String, dynamic>> getIntegrationsData() async {
    try {
      final response = await _apiService.get('/integrations');
      final data = response.data;

      if (data is Map<String, dynamic> && data['integrations'] != null) {
        final integrationsMap = data['integrations'] as Map<String, dynamic>;
        
        final shopify = integrationsMap['shopify'] != null
            ? ShopifyIntegrationModel.fromJson(integrationsMap['shopify'] as Map<String, dynamic>)
            : null;

        final woocommerce = integrationsMap['woocommerce'] != null
            ? WooCommerceIntegrationModel.fromJson(integrationsMap['woocommerce'] as Map<String, dynamic>)
            : null;

        return {
          'success': true,
          'shopify': shopify,
          'woocommerce': woocommerce,
        };
      }
      return {'success': false};
    } catch (e) {
      return {
        'success': false,
        'error': ApiService.extractErrorMessage(e, 'Failed to fetch integrations data'),
      };
    }
  }

  Future<Map<String, dynamic>> updateIntegration(Map<String, dynamic> payload) async {
    try {
      final response = await _apiService.patch('/integrations', data: payload);
      final data = response.data;
      return {
        'success': data['success'] ?? true,
        'message': data['message'] ?? 'Integration updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'error': ApiService.extractErrorMessage(e, 'Failed to update integration'),
      };
    }
  }

  Future<Map<String, dynamic>> getTemplates() async {
    try {
      final response = await _apiService.get('/templates');
      final data = response.data;
      return {
        'success': true,
        'data': data['data'] ?? data['templates'] ?? [],
      };
    } catch (e) {
      return {
        'success': false,
        'error': ApiService.extractErrorMessage(e, 'Failed to fetch templates'),
      };
    }
  }
}

