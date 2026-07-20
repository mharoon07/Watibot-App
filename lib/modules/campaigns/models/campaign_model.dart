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
