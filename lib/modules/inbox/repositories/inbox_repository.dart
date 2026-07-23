import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;


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
        'messages_only': 'true',
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
      print('Error marking as read: $e');
    }
  }

  Future<Map<String, dynamic>> uploadMedia({
    required String filePath,
    required String fileName,
    void Function(int sentBytes, int totalBytes)? onProgress,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await _apiService.post(
      '/media',
      data: formData,
      onSendProgress: onProgress,
    );

    final data = response.data;
    if (data != null && (data['success'] == true || data['url'] != null)) {
      return {
        'success': true,
        'url': data['url'] ?? data['data']?['url'],
        'type': data['type'] ?? data['media_type'] ?? 'document',
        'filename': data['filename'] ?? fileName,
      };
    }
    throw ApiException(message: ApiService.extractErrorMessage(data, 'Media upload failed'));
  }

  Future<MessageModel> sendLiveChatMessage({
    required String contactId,
    String? message,
    String? mediaUrl,
    String? contentType,
    String? templateName,
    String? templateLanguage,
    List<dynamic>? components,
    String? senderId,
  }) async {
    final payload = {
      'contact_id': contactId,
      'message': message ?? '',

      if (mediaUrl != null && mediaUrl.isNotEmpty) 'media_url': mediaUrl,
      if (contentType != null && contentType.isNotEmpty) 'content_type': contentType,
      if (templateName != null && templateName.isNotEmpty) 'template_name': templateName,
      if (templateLanguage != null && templateLanguage.isNotEmpty) 'language': templateLanguage,
      if (components != null && components.isNotEmpty) 'components': components,
      if (senderId != null && senderId.isNotEmpty) 'sender_id': senderId,
    };

    final response = await _apiService.post('/live-chat', data: payload);
    final data = response.data;
    if (data != null && (data['success'] == true || data['message'] != null)) {
      final msgJson = data['message'] ?? data['latest_message'] ?? data;
      return MessageModel.fromJson(msgJson);
    }
    throw ApiException(message: ApiService.extractErrorMessage(data, 'Failed to send message'));
  }

  Future<List<Map<String, dynamic>>> fetchQuickReplies() async {
    try {
      final response = await _apiService.get('/quick-replies');
      final data = response.data;
      if (data != null) {
        final rawList = data['data'] ?? data['quick_replies'] ?? data['quickReplies'] ?? [];
        if (rawList is List) {
          return rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchWhatsAppTemplates() async {
    try {
      final response = await _apiService.get('/templates');
      final data = response.data;
      final rawList = data['data'] ?? data['templates'] ?? [];
      if (rawList is List) {
        return rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}

