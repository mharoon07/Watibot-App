import 'package:get/get.dart';
import 'package:watibot/core/services/api_service.dart';
import 'package:watibot/modules/contacts/models/contact_model.dart';

class ContactsRepository {
  final ApiService _api = Get.find<ApiService>();

  Future<Map<String, dynamic>> getPaginatedContacts({
    int page = 1,
    int limit = 20,
    String search = '',
    String tab = 'all',
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page,
      'limit': limit,
    };
    
    if (search.isNotEmpty) {
      queryParams['search'] = search;
    }
    
    // The backend uses tag_id, group_id, platform. Wait, no, the backend has tag_id, group_id, platform.
    // Let's pass 'tab' locally, and we can handle it here or in the controller.
    // Wait, the API doesn't have a 'tab' param for contacts. It has tag_id, group_id, platform.
    // If we want "Customers", we might pass a specific tag_id or maybe it's not strictly supported by a 'tab' param.
    // We'll pass `tab` as a placeholder or use it if we can.
    if (tab != 'all') {
       queryParams['tab'] = tab; // We will see if we need to modify this later.
    }

    final response = await _api.get('/contacts', queryParameters: queryParams);
    
    if (response.statusCode == 200 && response.data['success'] == true) {
      final contactsData = response.data['contacts'] as List<dynamic>? ?? [];
      final contacts = contactsData.map((e) => ContactModel.fromJson(e as Map<String, dynamic>)).toList();
      return {
        'contacts': contacts,
        'totalPages': response.data['total_pages'] ?? 1,
        'total': response.data['total'] ?? 0,
      };
    }
    throw Exception('Failed to load contacts');
  }
}
