import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watibot/core/theme/app_theme.dart';
import 'package:watibot/modules/inbox/controllers/chat_controller.dart';
import 'package:watibot/modules/inbox/models/message_model.dart';
import 'package:watibot/modules/inbox/widgets/chat_app_bar.dart';
import 'package:watibot/modules/inbox/widgets/chat_bubble.dart';
import 'package:watibot/modules/inbox/widgets/date_separator.dart';
import 'package:watibot/modules/inbox/widgets/message_input.dart';
import 'package:watibot/modules/inbox/widgets/system_event_chip.dart';
import 'package:watibot/modules/inbox/widgets/typing_indicator.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slight off-white background like WhatsApp
      appBar: ChatAppBar(conversation: controller.conversation),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
              }

              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: controller.messages.length + (controller.isTyping.value ? 1 : 0),
                itemBuilder: (context, index) {
                  // Typing indicator at the bottom
                  if (index == controller.messages.length) {
                    return const TypingIndicator();
                  }

                  final message = controller.messages[index];
                  
                  // Basic logic to show date separator for the first message or if day changes
                  bool showDate = false;
                  if (index == 0) {
                    showDate = true;
                  } else {
                    final prevMessage = controller.messages[index - 1];
                    final current = message.timestamp;
                    final prev = prevMessage.timestamp;
                    if (current.year != prev.year || current.month != prev.month || current.day != prev.day) {
                      showDate = true;
                    }
                  }

                  return Column(
                    children: [
                      if (showDate) DateSeparator(date: message.timestamp),
                      _buildMessage(message),
                    ],
                  );
                },
              );
            }),
          ),
          MessageInput(
            controller: controller.textController,
            onSend: controller.sendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(MessageModel message) {
    if (message.type == MessageType.system) {
      return SystemEventChip(text: message.content);
    }
    return ChatBubble(message: message);
  }
}
