import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watibot/modules/inbox/models/conversation_model.dart';
import 'package:watibot/modules/inbox/models/message_model.dart';
import 'package:watibot/modules/inbox/repositories/inbox_repository.dart';

class ChatController extends GetxController {
  final InboxRepository _repository;
  
  // Passed argument
  late final ConversationModel conversation;

  ChatController(this._repository);

  final messages = <MessageModel>[].obs;
  final isLoading = true.obs;
  final isTyping = false.obs;

  final textController = TextEditingController();
  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    conversation = Get.arguments as ConversationModel;
    fetchMessages();
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchMessages() async {
    isLoading.value = true;
    try {
      final data = await _repository.getMessages(conversation.id);
      messages.assignAll(data);
      _scrollToBottom();
    } finally {
      isLoading.value = false;
    }
  }

  void sendMessage() {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    final newMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      timestamp: DateTime.now(),
      type: MessageType.outgoing,
      status: MessageStatus.sent,
    );

    messages.add(newMessage);
    textController.clear();
    _scrollToBottom();

    // Simulate delivery and read receipts
    _simulateMessageStatus(newMessage.id);
  }

  Future<void> _simulateMessageStatus(String messageId) async {
    // Simulate Delivery
    await Future.delayed(const Duration(seconds: 1));
    _updateMessageStatus(messageId, MessageStatus.delivered);

    // Simulate Read
    await Future.delayed(const Duration(seconds: 2));
    _updateMessageStatus(messageId, MessageStatus.read);

    // Simulate Reply
    _simulateReply();
  }

  void _updateMessageStatus(String messageId, MessageStatus status) {
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final old = messages[index];
      messages[index] = MessageModel(
        id: old.id,
        content: old.content,
        timestamp: old.timestamp,
        type: old.type,
        status: status,
        attachmentType: old.attachmentType,
        attachmentUrl: old.attachmentUrl,
        senderName: old.senderName,
      );
    }
  }

  Future<void> _simulateReply() async {
    isTyping.value = true;
    _scrollToBottom();
    
    await Future.delayed(const Duration(seconds: 3));
    
    isTyping.value = false;
    messages.add(
      MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'I understand. Please go ahead and process it.',
        timestamp: DateTime.now(),
        type: MessageType.incoming,
      )
    );
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 100, // Extra padding
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
