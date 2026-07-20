import 'package:watibot/modules/inbox/models/message_model.dart';

class ConversationModel {
  final String id;
  final String customerName;
  final String customerAvatar;
  final String customerPhone;
  final MessageModel lastMessage;
  final int unreadCount;
  final bool isOnline;
  final bool isPinned;
  final bool handledByAi;
  final String priority; // 'high', 'medium', 'low'
  final bool isVerified;
  final String? assignedAgent;

  ConversationModel({
    required this.id,
    required this.customerName,
    required this.customerAvatar,
    required this.customerPhone,
    required this.lastMessage,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isPinned = false,
    this.handledByAi = false,
    this.priority = 'medium',
    this.isVerified = false,
    this.assignedAgent,
  });
}
