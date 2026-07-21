class WorkspaceStatusModel {
  final String id;
  final String name;
  final String slug;
  final String? email;
  final String plan;
  final String timezone;
  final String? logo;
  final bool whatsappConnected;
  final String? whatsappNumber;
  final String? whatsappPhoneNumberId;
  final String? whatsappBusinessId;

  WorkspaceStatusModel({
    required this.id,
    required this.name,
    required this.slug,
    this.email,
    required this.plan,
    required this.timezone,
    this.logo,
    required this.whatsappConnected,
    this.whatsappNumber,
    this.whatsappPhoneNumberId,
    this.whatsappBusinessId,
  });

  factory WorkspaceStatusModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceStatusModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      email: json['email'],
      plan: json['plan'] ?? 'free',
      timezone: json['timezone'] ?? 'UTC',
      logo: json['logo'],
      whatsappConnected: json['whatsapp_connected'] ?? false,
      whatsappNumber: json['whatsapp_number'],
      whatsappPhoneNumberId: json['whatsapp_phone_number_id'],
      whatsappBusinessId: json['whatsapp_business_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'email': email,
      'plan': plan,
      'timezone': timezone,
      'logo': logo,
      'whatsapp_connected': whatsappConnected,
      'whatsapp_number': whatsappNumber,
      'whatsapp_phone_number_id': whatsappPhoneNumberId,
      'whatsapp_business_id': whatsappBusinessId,
    };
  }
}
