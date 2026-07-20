class DashboardModel {
  final int totalMessages;
  final double messageGrowth;
  final List<double> messageChartData;
  final List<Statistic> statistics;
  final List<RecentActivity> recentActivities;

  DashboardModel({
    required this.totalMessages,
    required this.messageGrowth,
    required this.messageChartData,
    required this.statistics,
    required this.recentActivities,
  });
}

class Statistic {
  final String title;
  final String value;
  final double trend;
  final String iconCode;

  Statistic({
    required this.title,
    required this.value,
    required this.trend,
    required this.iconCode,
  });
}

class RecentActivity {
  final String title;
  final String subtitle;
  final String timestamp;
  final String type; // 'campaign', 'contact', 'flow', 'broadcast', 'agent', 'payment'

  RecentActivity({
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.type,
  });
}
