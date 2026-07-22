class MessageModel {
  final String id;
  final String content;

  final DateTime timestamp;
  final MessageType type;
  final MessageStatus status;
  final String? attachmentUrl;
  final AttachmentType? attachmentType;
  final String? senderName;
  final double uploadProgress;





  MessageModel({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.type,
    this.status = MessageStatus.none,
    this.attachmentUrl,
    this.attachmentType,
    this.senderName,
    this.uploadProgress = 1.0,
  });


  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final rawType = json['type']?.toString() ?? '';
    final rawContentType = json['content_type']?.toString() ?? json['contentType']?.toString() ?? '';
    final effectiveType = (rawContentType.isNotEmpty && rawContentType != 'text') ? rawContentType : rawType;

    return MessageModel(
      id: json['id']?.toString() ?? '',
      content: _sanitizeContent(json['content']?.toString() ?? json['text']?.toString() ?? '', effectiveType),
      timestamp: json['created_at_iso'] != null 
          ? DateTime.tryParse(json['created_at_iso'].toString()) ?? DateTime.now()
          : (json['created_at'] != null 
              ? DateTime.fromMillisecondsSinceEpoch(int.tryParse(json['created_at'].toString()) ?? DateTime.now().millisecondsSinceEpoch)
              : DateTime.now()),
      type: _parseMessageType(rawType, json['direction']?.toString() ?? ''),
      status: _parseMessageStatus(json['status']?.toString() ?? ''),
      attachmentUrl: _parseMediaUrl(json['media_url']?.toString() ?? json['mediaUrl']?.toString()),
      attachmentType: _parseAttachmentType(effectiveType),
      senderName: json['sender_name']?.toString() ?? json['sender']?['name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'created_at_iso': timestamp.toIso8601String(),
      'direction': type == MessageType.outgoing || type == MessageType.ai || type == MessageType.system ? 'outbound' : 'inbound',
      'type': type == MessageType.ai ? 'ai' : (type == MessageType.system ? 'system' : 'text'),
      'status': status.name,
      'media_url': attachmentUrl,
      'content_type': attachmentType?.name ?? 'text',
      'sender_name': senderName,
    };
  }

  MessageModel copyWith({
    String? id,
    String? content,
    DateTime? timestamp,
    MessageType? type,
    MessageStatus? status,
    String? attachmentUrl,
    AttachmentType? attachmentType,
    String? senderName,
    double? uploadProgress,
  }) {
    return MessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      status: status ?? this.status,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentType: attachmentType ?? this.attachmentType,
      senderName: senderName ?? this.senderName,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }


  static String _sanitizeContent(String content, String type) {
    if (content == 'Template: undefined' || content == 'Template: null') {
      return '';
    }
    final lowerType = type.toLowerCase();
    if (lowerType == 'image' || lowerType == 'video' || lowerType == 'audio' || lowerType == 'voice') {
      if (content.startsWith('scaled_') || content.endsWith('.jpg') || content.endsWith('.jpeg') || content.endsWith('.png') || content.startsWith('http://') || content.startsWith('https://')) {
        return '';
      }
    }
    return content;
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
