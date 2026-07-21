import 'package:get/get.dart';
import 'package:watibot/core/services/api_service.dart';
import 'package:watibot/modules/inbox/models/conversation_model.dart';
import 'package:watibot/modules/inbox/models/message_model.dart';

class InboxRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<Map<String, dynamic>> getPaginatedConversations({
    int page = 1,
    int limit = 50,
    String? search,
    String? tab,
    String? requesterId,
    String? requesterEmail,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (tab != null && tab != 'all') 'tab': tab,
        if (requesterId != null && requesterId.isNotEmpty) 'requester_id': requesterId,
        if (requesterEmail != null && requesterEmail.isNotEmpty) 'requester_email': requesterEmail,
      };

      final response = await _apiService.get('/live-chat', queryParameters: queryParams);
      
      final data = response.data;
      if (data != null && data['success'] == true) {
        final List<dynamic> contactsJson = data['contacts'] ?? [];
        return {
          'conversations': contactsJson.map((json) => ConversationModel.fromJson(json)).toList(),
          'hasMore': data['contacts_has_more'] ?? false,
          'total': data['total'] ?? 0,
        };
      }
      throw ApiException(message: 'Invalid response format');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPaginatedMessages(String contactId, {
    int messagePage = 1,
    int messageLimit = 50,
  }) async {
    try {
      final queryParams = {
        'contact_id': contactId,
        'message_page': messagePage,
        'message_limit': messageLimit,
        'limit': 1, // Minimize payload size since we only care about messages
      };

      final response = await _apiService.get('/live-chat', queryParameters: queryParams);
      
      final data = response.data;
      if (data != null && data['success'] == true) {
        final List<dynamic> messagesJson = data['messages'] ?? [];
        return {
          'messages': messagesJson.map((json) => MessageModel.fromJson(json)).toList(),
          'hasMore': data['messages_has_more'] ?? false,
          'total': data['messages_total'] ?? 0,
        };
      }
      throw ApiException(message: 'Invalid response format');
    } catch (e) {
      rethrow;
    }
  }

  // Fallback for mock-like quick access or legacy calls
  Future<List<ConversationModel>> getConversations() async {
    final res = await getPaginatedConversations();
    return res['conversations'] as List<ConversationModel>;
  }

  Future<List<MessageModel>> getMessages(String contactId) async {
    final res = await getPaginatedMessages(contactId);
    return res['messages'] as List<MessageModel>;
  }

  Future<void> markAsRead(String contactId) async {
    try {
      await _apiService.post(
        '/live-chat/conversations/read',
        data: {'contact_id': contactId},
      );
    } catch (e) {
      // We can swallow the error here or log it, as read receipts aren't critical enough to crash the UI
      print('Error marking as read: $e');
    }
  }
}
