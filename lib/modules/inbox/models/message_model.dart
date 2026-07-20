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
