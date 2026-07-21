class CampaignModel {
  final String id;
  final String name;
  final String type; // 'Broadcast', 'Automation', 'Drip', 'Newsletter'
  final CampaignStatus status;
  final DateTime createdAt;
  final int audienceCount;
  final String owner;

  // Metrics
  final int messagesSent;
  final double deliveryRate; // 0.0 to 1.0
  final double openRate; // 0.0 to 1.0
  final double clickRate; // 0.0 to 1.0
  final double replyRate; // 0.0 to 1.0
  final double deliveryProgress; // 0.0 to 1.0, used when 'Sending'

  CampaignModel({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.audienceCount,
    required this.owner,
    this.messagesSent = 0,
    this.deliveryRate = 0.0,
    this.openRate = 0.0,
    this.clickRate = 0.0,
    this.replyRate = 0.0,
    this.deliveryProgress = 0.0,
  });

  bool get isDynamicAudience => audienceCount == -1;

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    int attempts = json['attempts'] ?? 0;
    int audience = json['audience_count'] ?? 0;
    
    // Calculate actual progress based on attempts vs audience
    double progress = 0.0;
    if (audience > 0) {
      progress = (attempts / audience).clamp(0.0, 1.0);
    } else if (json['status'] == 'SENT' || json['status'] == 'COMPLETED') {
      progress = 1.0;
    }

    return CampaignModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['template_name']?.toString() ?? 'Untitled Campaign',
      type: json['type']?.toString().toUpperCase() == 'DRIP' ? 'Drip' 
            : json['type']?.toString().toUpperCase() == 'BROADCAST' ? 'Broadcast' 
            : 'Automation',
      status: _parseStatus(json['status']?.toString() ?? ''),
      createdAt: json['scheduled_at_iso'] != null 
          ? DateTime.tryParse(json['scheduled_at_iso'].toString()) ?? DateTime.now()
          : DateTime.now(),
      audienceCount: audience,
      owner: 'Admin',
      messagesSent: attempts,
      deliveryRate: (json['delivery_rate'] ?? 0.0).toDouble(),
      openRate: (json['open_rate'] ?? 0.0).toDouble(),
      clickRate: (json['click_rate'] ?? 0.0).toDouble(),
      replyRate: (json['reply_rate'] ?? 0.0).toDouble(),
      deliveryProgress: progress,
    );
  }

  static CampaignStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
      case 'SCHEDULED':
        return CampaignStatus.scheduled;
      case 'SENT':
      case 'COMPLETED':
        return CampaignStatus.completed;
      case 'FAILED':
        return CampaignStatus.paused;
      case 'RUNNING':
      case 'SENDING':
        return CampaignStatus.sending;
      default:
        return CampaignStatus.draft;
    }
  }
}

enum CampaignStatus {
  sending,
  scheduled,
  running,
  completed,
  paused,
  draft,
  archived
}
