import 'package:watibot/modules/home/models/dashboard_model.dart';

class HomeRepository {
  Future<DashboardModel> getDashboardData() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    return DashboardModel(
      totalMessages: 142504,
      messageGrowth: 12.5,
      messageChartData: [0.2, 0.4, 0.3, 0.6, 0.5, 0.8, 0.6, 0.9, 0.7, 1.0],
      statistics: [
        Statistic(title: 'Total Contacts', value: '12,450', trend: 5.0, iconCode: 'people'),
        Statistic(title: 'Total Flows', value: '48', trend: 2.0, iconCode: 'account_tree'),
        Statistic(title: 'Total Campaigns', value: '156', trend: 8.0, iconCode: 'rocket_launch'),
        Statistic(title: 'Active Agents', value: '12', trend: -1.0, iconCode: 'smart_toy'),

      ],
      recentActivities: [
        RecentActivity(
          title: 'Black Friday Promo',
          subtitle: 'Campaign completed',
          timestamp: '2 mins ago',
          type: 'campaign',
        ),
        RecentActivity(
          title: 'Sarah Jenkins',
          subtitle: 'New Contact added to list',
          timestamp: '15 mins ago',
          type: 'contact',
        ),
        RecentActivity(
          title: 'SupportBot Alpha',
          subtitle: 'AI Agent paused',
          timestamp: '1 hour ago',
          type: 'agent',
        ),
        RecentActivity(
          title: 'Welcome Flow v2',
          subtitle: 'Flow Published successfully',
          timestamp: '3 hours ago',
          type: 'flow',
        ),
        RecentActivity(
          title: 'Weekend Sale Update',
          subtitle: 'Broadcast Delivered to 5k users',
          timestamp: '5 hours ago',
          type: 'broadcast',
        ),
      ],
    );
  }
}
