class ContactTagModel {
  final String id;
  final String name;
  final String? color;
  final String? category;

  ContactTagModel({
    required this.id,
    required this.name,
    this.color,
    this.category,
  });

  factory ContactTagModel.fromJson(Map<String, dynamic> json) {
    return ContactTagModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      color: json['color'],
      category: json['category'],
    );
  }
}

class ContactModel {
  final String id;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? waId;
  final String platform;
  final String? profilePic;
  final String? notes;
  final Map<String, dynamic> attributes;
  final bool isBlocked;
  final bool isAiBotEnabled;
  final int unreadCount;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final DateTime? lastInboundMessageAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ContactTagModel> tags;

  ContactModel({
    required this.id,
    this.name,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.waId,
    this.platform = 'WHATSAPP',
    this.profilePic,
    this.notes,
    this.attributes = const {},
    this.isBlocked = false,
    this.isAiBotEnabled = true,
    this.unreadCount = 0,
    this.lastMessage,
    this.lastMessageAt,
    this.lastInboundMessageAt,
    this.createdAt,
    this.updatedAt,
    this.tags = const [],
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'] ?? '',
      name: json['name'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      waId: json['wa_id'],
      platform: json['platform'] ?? 'WHATSAPP',
      profilePic: json['profile_pic'],
      notes: json['notes'],
      attributes: json['attributes'] != null && json['attributes'] is Map
          ? Map<String, dynamic>.from(json['attributes'])
          : {},
      isBlocked: json['is_blocked'] ?? false,
      isAiBotEnabled: json['is_ai_bot_enabled'] ?? true,
      unreadCount: json['unread_count'] ?? 0,
      lastMessage: json['last_message'],
      lastMessageAt: json['last_message_at_iso'] != null
          ? DateTime.tryParse(json['last_message_at_iso'])
          : null,
      lastInboundMessageAt: json['last_inbound_message_at_iso'] != null
          ? DateTime.tryParse(json['last_inbound_message_at_iso'])
          : null,
      createdAt: json['created_at_iso'] != null
          ? DateTime.tryParse(json['created_at_iso'])
          : null,
      updatedAt: json['updated_at_iso'] != null
          ? DateTime.tryParse(json['updated_at_iso'])
          : null,
      tags: json['tags'] != null && json['tags'] is List
          ? (json['tags'] as List).map((e) => ContactTagModel.fromJson(Map<String, dynamic>.from(e))).toList()
          : [],
    );
  }

  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    if (firstName != null && firstName!.isNotEmpty) {
      return [firstName, lastName].where((e) => e != null && e.isNotEmpty).join(' ');
    }
    if (phoneNumber != null && phoneNumber!.isNotEmpty) return phoneNumber!;
    if (waId != null && waId!.isNotEmpty) return '+$waId';
    return 'Unknown Contact';
  }

  String get initials {
    final dName = displayName;
    if (dName == 'Unknown Contact' || dName.startsWith('+')) return '?';
    final parts = dName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'.toUpperCase();
  }
}
