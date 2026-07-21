import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watibot/modules/inbox/models/conversation_model.dart';
import 'package:watibot/modules/inbox/models/message_model.dart';
import 'package:watibot/modules/inbox/repositories/inbox_repository.dart';
import 'package:watibot/modules/inbox/controllers/inbox_controller.dart';

class ChatController extends GetxController {
  final InboxRepository _repository;
  
  // Passed argument
  late final ConversationModel conversation;

  ChatController(this._repository);

  final messages = <MessageModel>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final isTyping = false.obs;

  final textController = TextEditingController();
  final scrollController = ScrollController();

  int _currentPage = 1;
  bool _hasMore = true;
  Timer? _pollingTimer;

  @override
  void onInit() {
    super.onInit();
    conversation = Get.arguments as ConversationModel;
    fetchMessages();
    _markChatAsRead();

    scrollController.addListener(_onScroll);
    
    // Start silent polling every 5 seconds for new messages and status updates
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      pollMessages();
    });
  }

  void _markChatAsRead() {
    if (conversation.unreadCount > 0) {
      // 1. Update UI immediately via InboxController
      try {
        final inboxController = Get.find<InboxController>();
        inboxController.markAsRead(conversation.id);
      } catch (e) {
        debugPrint('InboxController not found or error marking as read: $e');
      }

      // 2. Hit the backend API to reset unread count and send Meta read receipt
      _repository.markAsRead(conversation.id);
    }
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    scrollController.dispose();
    textController.dispose();
    super.onClose();
  }

  void _onScroll() {
    // In ChatView, the list is reversed.
    // So scrolling to the "bottom" (maxScrollExtent) means scrolling UP to older messages.
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      loadOlderMessages();
    }
  }

  Future<void> fetchMessages() async {
    _currentPage = 1;
    isLoading.value = true;
    try {
      final data = await _repository.getPaginatedMessages(
        conversation.id,
        messagePage: _currentPage,
      );
      
      final list = (data['messages'] as List<MessageModel>).reversed.toList();
      messages.assignAll(list);
      _hasMore = data['hasMore'] as bool;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pollMessages() async {
    try {
      final data = await _repository.getPaginatedMessages(
        conversation.id,
        messagePage: 1,
      );
      
      final fetchedList = data['messages'] as List<MessageModel>;
      // Messages are returned newest first. Process them in reverse to insert newest last at index 0.
      for (var newMsg in fetchedList.reversed) {
        final index = messages.indexWhere((m) => m.id == newMsg.id);
        if (index != -1) {
          if (messages[index].status != newMsg.status || messages[index].content != newMsg.content) {
            messages[index] = newMsg;
          }
        } else {
          messages.insert(0, newMsg);
        }
      }
    } catch (e) {
      debugPrint('Silent poll failed: $e');
    }
  }

  Future<void> loadOlderMessages() async {
    if (isLoadingMore.value || !_hasMore || isLoading.value) return;

    isLoadingMore.value = true;
    try {
      _currentPage++;
      final data = await _repository.getPaginatedMessages(
        conversation.id,
        messagePage: _currentPage,
      );
      
      final newMessages = (data['messages'] as List<MessageModel>).reversed.toList();
      _hasMore = data['hasMore'] as bool;

      // Append older messages to the end of the reversed list
      for (var msg in newMessages) {
        if (!messages.any((m) => m.id == msg.id)) {
          messages.add(msg);
        }
      }
    } catch (e) {
      _currentPage--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  void sendMessage() {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    final newMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID until backend syncs
      content: text,
      timestamp: DateTime.now(),
      type: MessageType.outgoing,
      status: MessageStatus.sent, // Should be pending, then sent via API
    );

    messages.insert(0, newMessage); // Insert at 0 because reversed list
    textController.clear();
    _scrollToBottom(); // Which is scroll to 0.0

    // TODO: Connect this to actual backend POST /api/v1/live-chat/messages
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void openContactDetails() {
    Get.toNamed('/contacts/details', arguments: conversation);
  }
}
