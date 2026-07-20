import 'package:watibot/modules/inbox/models/conversation_model.dart';
import 'package:watibot/modules/inbox/models/message_model.dart';

class InboxRepository {
  Future<List<ConversationModel>> getConversations() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network

    return [
      ConversationModel(
        id: '1',
        customerName: 'Sarah Jenkins',
        customerAvatar: 'https://i.pravatar.cc/150?img=47',
        customerPhone: '+1 (555) 123-4567',
        unreadCount: 2,
        isOnline: true,
        handledByAi: true,
        priority: 'high',
        lastMessage: MessageModel(
          id: 'm1',
          content: 'I need to speak with a real person about order #4829',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          type: MessageType.incoming,
        ),
      ),
      ConversationModel(
        id: '2',
        customerName: 'Marcus R.',
        customerAvatar: 'https://i.pravatar.cc/150?img=11',
        customerPhone: '+44 7700 900077',
        unreadCount: 0,
        isOnline: false,
        handledByAi: true,
        isPinned: true,
        lastMessage: MessageModel(
          id: 'm2',
          content: 'Thank you, the automated booking worked perfectly!',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          type: MessageType.outgoing,
          status: MessageStatus.read,
        ),
      ),
      ConversationModel(
        id: '3',
        customerName: 'TechNova Solutions',
        customerAvatar: 'https://i.pravatar.cc/150?img=33',
        customerPhone: '+1 (800) 555-0199',
        unreadCount: 0,
        isOnline: false,
        isVerified: true,
        assignedAgent: 'Michael',
        lastMessage: MessageModel(
          id: 'm3',
          content: 'What are your enterprise API limits?',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          type: MessageType.outgoing,
          status: MessageStatus.delivered,
        ),
      ),
      ConversationModel(
        id: '4',
        customerName: 'John Doe',
        customerAvatar: 'https://i.pravatar.cc/150?img=60',
        customerPhone: '+1 (555) 987-6543',
        unreadCount: 0,
        isOnline: false,
        lastMessage: MessageModel(
          id: 'm4',
          content: 'Can I get a copy of my last invoice?',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          type: MessageType.outgoing,
          status: MessageStatus.sent,
        ),
      ),
      ConversationModel(
        id: '5',
        customerName: 'Emily Clark',
        customerAvatar: 'https://i.pravatar.cc/150?img=5',
        customerPhone: '+1 (555) 222-3344',
        unreadCount: 5,
        isOnline: true,
        priority: 'high',
        assignedAgent: 'Michael',
        lastMessage: MessageModel(
          id: 'm5',
          content: 'My delivery is late and I need it today!!',
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
          type: MessageType.incoming,
        ),
      ),
    ];
  }

  Future<List<MessageModel>> getMessages(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock chat for Sarah Jenkins
    if (conversationId == '1') {
      final now = DateTime.now();
      return [
        MessageModel(
          id: 'sys1',
          content: 'Customer initiated conversation',
          timestamp: now.subtract(const Duration(hours: 1)),
          type: MessageType.system,
        ),
        MessageModel(
          id: 'msg1',
          content: 'Hi, I\'m trying to update my shipping address for order #4829, but the system isn\'t letting me.',
          timestamp: now.subtract(const Duration(minutes: 55)),
          type: MessageType.incoming,
        ),
        MessageModel(
          id: 'msg2',
          content: 'Hello Sarah! I can help with that. Since order #4829 is already in the \'Processing\' stage, I\'ll need to flag this for manual review by our fulfillment team.\n\nProposed New Address:\n123 New Way St, Apt 4\nAustin, TX 78701\n\nShall I submit this update request for you?',
          timestamp: now.subtract(const Duration(minutes: 54)),
          type: MessageType.ai,
          senderName: 'WatiBot AI',
          status: MessageStatus.read,
        ),
        MessageModel(
          id: 'msg3',
          content: 'Yes please, that would be great. Thank you!',
          timestamp: now.subtract(const Duration(minutes: 52)),
          type: MessageType.incoming,
        ),
        MessageModel(
          id: 'sys2',
          content: 'Agent Michael took over the conversation',
          timestamp: now.subtract(const Duration(minutes: 50)),
          type: MessageType.system,
        ),
        MessageModel(
          id: 'msg4',
          content: 'I\'ve submitted the request, Sarah. You should receive a confirmation email within 1 hour.',
          timestamp: now.subtract(const Duration(minutes: 48)),
          type: MessageType.outgoing,
          senderName: 'Michael',
          status: MessageStatus.read,
        ),
        MessageModel(
          id: 'msg5',
          content: 'I need to speak with a real person about order #4829',
          timestamp: now.subtract(const Duration(minutes: 5)),
          type: MessageType.incoming,
        ),
      ];
    }
    
    // Default mock
    return [
      MessageModel(
        id: 'def1',
        content: 'Hello, how can we help you today?',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: MessageType.outgoing,
        status: MessageStatus.read,
      )
    ];
  }
}
