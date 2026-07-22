import 'package:watibot/modules/inbox/models/message_model.dart';

class ConversationModel {
  final String id;
  final String customerName;
  final String customerAvatar;
  final String customerPhone;
  final MessageModel? lastMessage;
  final DateTime lastMessageAt;
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
    required this.lastMessageAt,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isPinned = false,
    this.handledByAi = false,
    this.priority = 'medium',
    this.isVerified = false,
    this.assignedAgent,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final lastMessageAt = json['last_message_at_iso'] != null 
        ? DateTime.tryParse(json['last_message_at_iso'].toString()) ?? DateTime.now()
        : (json['last_message_at'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(int.tryParse(json['last_message_at'].toString()) ?? DateTime.now().millisecondsSinceEpoch)
            : DateTime.now());

    return ConversationModel(
      id: json['id']?.toString() ?? '',
      customerName: json['name']?.toString() ?? json['wa_id']?.toString() ?? 'Unknown',
      customerAvatar: json['profile_pic']?.toString() ?? '',
      customerPhone: json['wa_id']?.toString() ?? '',
      lastMessage: json['latest_message'] != null 
          ? MessageModel.fromJson(json['latest_message']) 
          : null,
      lastMessageAt: lastMessageAt,
      unreadCount: json['unread_count'] ?? 0,
      handledByAi: json['is_ai_bot_enabled'] ?? false,
      isVerified: json['is_verified'] ?? false,
      isPinned: false, // Currently not in API, defaults to false
      priority: 'medium', // Default
      assignedAgent: json['assigned_users'] != null && (json['assigned_users'] as List).isNotEmpty
          ? (json['assigned_users'] as List)[0]['name']?.toString()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': customerName,
      'profile_pic': customerAvatar,
      'wa_id': customerPhone,
      'latest_message': lastMessage?.toJson(),
      'last_message_at_iso': lastMessageAt.toIso8601String(),
      'unread_count': unreadCount,
      'is_ai_bot_enabled': handledByAi,
      'is_verified': isVerified,
      'assigned_users': assignedAgent != null ? [{'name': assignedAgent}] : [],
    };
  }

  ConversationModel copyWith({
    String? id,
    String? customerName,
    String? customerAvatar,
    String? customerPhone,
    MessageModel? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
    bool? isOnline,
    bool? isPinned,
    bool? handledByAi,
    String? priority,
    bool? isVerified,
    String? assignedAgent,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerAvatar: customerAvatar ?? this.customerAvatar,
      customerPhone: customerPhone ?? this.customerPhone,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      isPinned: isPinned ?? this.isPinned,
      handledByAi: handledByAi ?? this.handledByAi,
      priority: priority ?? this.priority,
      isVerified: isVerified ?? this.isVerified,
      assignedAgent: assignedAgent ?? this.assignedAgent,
    );
  }

  String get displayAvatar {
    if (customerAvatar.isNotEmpty) return customerAvatar;
    final name = customerName.isEmpty ? customerPhone : customerName;
    final displayName = name.isEmpty ? 'User' : name;
    // Extract first two letters/digits manually to ensure consistency with Web
    String initials = '';
    if (RegExp(r'^\d').hasMatch(displayName)) {
      initials = displayName.length >= 2 ? displayName.substring(0, 2) : displayName[0];
    } else {
      final words = displayName.trim().split(RegExp(r'\s+'));
      if (words.length >= 2) {
        initials = '${words[0][0]}${words[1][0]}';
      } else {
        initials = displayName.length >= 2 ? displayName.substring(0, 2) : displayName[0];
      }
    }
    
    // Use consistent hashing for background color to match the name
    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(initials)}&background=random&color=fff&bold=true&size=128';
  }
}
