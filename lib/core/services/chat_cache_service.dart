import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watibot/modules/inbox/models/conversation_model.dart';
import 'package:watibot/modules/inbox/models/message_model.dart';

class ChatCacheService extends GetxService {
  late SharedPreferences _prefs;

  static const String _conversationsKey = 'cached_conversations_v1';
  static const String _messagesPrefix = 'cached_messages_v1_';

  final Map<String, List<MessageModel>> _memoryMessages = {};
  List<ConversationModel>? _memoryConversations;

  Future<ChatCacheService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // --- Conversations Caching ---

  Future<void> saveConversations(List<ConversationModel> conversations) async {
    try {
      _memoryConversations = List.from(conversations);
      final jsonList = conversations.map((c) => c.toJson()).toList();
      await _prefs.setString(_conversationsKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error caching conversations: $e');
    }
  }

  List<ConversationModel> getCachedConversations() {
    if (_memoryConversations != null && _memoryConversations!.isNotEmpty) {
      return List.from(_memoryConversations!);
    }

    try {
      final jsonString = _prefs.getString(_conversationsKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final list = jsonList.map((json) => ConversationModel.fromJson(Map<String, dynamic>.from(json))).toList();
        _memoryConversations = list;
        return List.from(list);
      }
    } catch (e) {
      debugPrint('Error loading cached conversations: $e');
    }
    return [];
  }

  // --- Messages Caching ---

  Future<void> saveMessages(String contactId, List<MessageModel> messages) async {
    if (contactId.isEmpty) return;
    try {
      _memoryMessages[contactId] = List.from(messages);
      final key = '$_messagesPrefix$contactId';
      // Cache up to 100 recent messages per chat to prevent storage bloat
      final toSave = messages.take(100).map((m) => m.toJson()).toList();
      await _prefs.setString(key, jsonEncode(toSave));
    } catch (e) {
      debugPrint('Error caching messages for $contactId: $e');
    }
  }

  List<MessageModel> getCachedMessages(String contactId) {
    if (contactId.isEmpty) return [];

    if (_memoryMessages.containsKey(contactId) && _memoryMessages[contactId]!.isNotEmpty) {
      return List.from(_memoryMessages[contactId]!);
    }

    try {
      final key = '$_messagesPrefix$contactId';
      final jsonString = _prefs.getString(key);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final list = jsonList.map((json) => MessageModel.fromJson(Map<String, dynamic>.from(json))).toList();
        _memoryMessages[contactId] = list;
        return List.from(list);
      }
    } catch (e) {
      debugPrint('Error loading cached messages for $contactId: $e');
    }
    return [];
  }

  void clearMemoryCache() {
    _memoryConversations = null;
    _memoryMessages.clear();
  }
}
