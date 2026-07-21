class MessageModel {
  final String id;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final MessageStatus status;
  final String? attachmentUrl;
  final AttachmentType? attachmentType;
  final String? senderName; // for AI/Agent transfers

  MessageModel({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.type,
    this.status = MessageStatus.none,
    this.attachmentUrl,
    this.attachmentType,
    this.senderName,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? json['text']?.toString() ?? '',
      timestamp: json['created_at_iso'] != null 
          ? DateTime.tryParse(json['created_at_iso'].toString()) ?? DateTime.now()
          : (json['created_at'] != null 
              ? DateTime.fromMillisecondsSinceEpoch(int.tryParse(json['created_at'].toString()) ?? DateTime.now().millisecondsSinceEpoch)
              : DateTime.now()),
      type: _parseMessageType(json['type']?.toString() ?? '', json['direction']?.toString() ?? ''),
      status: _parseMessageStatus(json['status']?.toString() ?? ''),
      attachmentUrl: _parseMediaUrl(json['media_url']?.toString()),
      attachmentType: _parseAttachmentType(json['type']?.toString() ?? ''),
      senderName: json['sender_name']?.toString() ?? json['sender']?['name']?.toString(),
    );
  }

  static String? _parseMediaUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    
    // Fix localhost issue for physical Android devices
    // Replace 'localhost' with the same IP used in ApiService.baseUrl
    if (url.startsWith('http://localhost:3000')) {
      return url.replaceFirst('http://localhost:3000', 'http://192.168.18.223:3000');
    }
    return url;
  }

  static MessageType _parseMessageType(String type, String direction) {
    if (direction == 'outbound') {
      if (type.toLowerCase() == 'ai') return MessageType.ai;
      if (type.toLowerCase() == 'system') return MessageType.system;
      return MessageType.outgoing;
    }
    return MessageType.incoming;
  }

  static MessageStatus _parseMessageStatus(String status) {
    switch (status.toLowerCase()) {
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      default:
        return MessageStatus.none; // failed, pending, or none
    }
  }

  static AttachmentType? _parseAttachmentType(String type) {
    switch (type.toLowerCase()) {
      case 'image': return AttachmentType.image;
      case 'video': return AttachmentType.video;
      case 'document': return AttachmentType.document;
      case 'audio': return AttachmentType.voice;
      case 'location': return AttachmentType.location;
      case 'contacts': return AttachmentType.contact;
      default: return null;
    }
  }
}

enum MessageType {
  incoming,
  outgoing,
  ai,
  system,
}

enum MessageStatus {
  none,
  sent,
  delivered,
  read,
}

enum AttachmentType {
  image,
  video,
  pdf,
  document,
  location,
  voice,
  contact,
}
