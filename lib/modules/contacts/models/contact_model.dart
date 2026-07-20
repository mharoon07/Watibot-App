class ContactModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String company;
  final String avatarUrl;
  final DateTime lastSeen;
  final ContactStatus status;
  final bool isFavorite;
  final List<String> tags;
  final DateTime lastInteraction;
  final bool isWhatsappVerified;
  final int unreadCount;

  ContactModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.company,
    required this.avatarUrl,
    required this.lastSeen,
    required this.status,
    this.isFavorite = false,
    this.tags = const [],
    required this.lastInteraction,
    this.isWhatsappVerified = false,
    this.unreadCount = 0,
  });
}

enum ContactStatus {
  customer,
  lead,
  vip,
  blocked,
  unknown
}
