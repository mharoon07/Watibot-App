class DashboardStatsModel {
  final int totalContacts;
  final int whatsappContacts;
  final int liveChats;
  final int unreadChats;
  final int activeContacts;
  final int totalMessages;
  final int inboundMessages;
  final int outboundMessages;
  final int campaignsSent;
  final int activeFlows;
  final int totalFlows;
  final int quickReplies;
  final int welcomeMessages;
  final int tags;
  final double messageGrowth;
  final List<double> messageChartData;

  DashboardStatsModel({
    required this.totalContacts,
    required this.whatsappContacts,
    required this.liveChats,
    required this.unreadChats,
    required this.activeContacts,
    required this.totalMessages,
    required this.inboundMessages,
    required this.outboundMessages,
    required this.campaignsSent,
    required this.activeFlows,
    required this.totalFlows,
    required this.quickReplies,
    required this.welcomeMessages,
    required this.tags,
    this.messageGrowth = 0.0,
    this.messageChartData = const [],
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    final metrics = json['metrics'] ?? {};
    final channels = json['channels'] ?? {};
    
    return DashboardStatsModel(
      totalContacts: metrics['contacts'] ?? 0,
      whatsappContacts: channels['whatsapp'] ?? 0,
      liveChats: metrics['live_chats'] ?? 0,
      unreadChats: metrics['unread_chats'] ?? 0,
      activeContacts: metrics['active_contacts'] ?? 0,
      totalMessages: metrics['messages'] ?? 0,
      inboundMessages: metrics['inbound_messages'] ?? 0,
      outboundMessages: metrics['outbound_messages'] ?? 0,
      campaignsSent: metrics['campaigns_sent'] ?? 0,
      activeFlows: metrics['active_flows'] ?? 0,
      totalFlows: metrics['total_flows'] ?? 0,
      quickReplies: metrics['quick_replies'] ?? 0,
      welcomeMessages: metrics['active_welcome_messages'] ?? 0,
      tags: metrics['audience_segments'] ?? 0,
      messageGrowth: (metrics['message_growth'] ?? 0).toDouble(),
      messageChartData: (metrics['message_chart_data'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metrics': {
        'contacts': totalContacts,
        'whatsapp_contacts': whatsappContacts,
        'live_chats': liveChats,
        'unread_chats': unreadChats,
        'active_contacts': activeContacts,
        'messages': totalMessages,
        'inbound_messages': inboundMessages,
        'outbound_messages': outboundMessages,
        'campaigns_sent': campaignsSent,
        'active_flows': activeFlows,
        'total_flows': totalFlows,
        'quick_replies': quickReplies,
        'welcome_messages': welcomeMessages,
        'tags': tags,
        'message_growth': messageGrowth,
        'message_chart_data': messageChartData,
      }
    };
  }
}
