import 'package:get/get.dart';
import 'package:watibot/core/services/api_service.dart';
import 'package:watibot/modules/home/models/dashboard_stats_model.dart';
import 'package:watibot/modules/home/models/recent_activity_model.dart';
import 'package:watibot/modules/home/models/usage_overview_model.dart';
import 'package:watibot/modules/home/models/workspace_status_model.dart';

class HomeRepository {
  final ApiService _api = Get.find<ApiService>();

  Future<Map<String, dynamic>> getDashboardData() async {
    final response = await _api.get('/dashboard');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data;
    }
    throw Exception('Failed to load dashboard data');
  }

  Future<DashboardStatsModel> getDashboardStats() async {
    final data = await getDashboardData();
    return DashboardStatsModel.fromJson(data['dashboard'] ?? {});
  }

  Future<WorkspaceStatusModel> getWorkspaceStatus() async {
    final data = await getDashboardData();
    return WorkspaceStatusModel.fromJson(data['project'] ?? {});
  }

  Future<UsageOverviewModel> getUsageOverview() async {
    final response = await _api.get('/quota');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return UsageOverviewModel.fromJson(response.data);
    }
    throw Exception('Failed to load usage overview');
  }

  Future<List<RecentActivityModel>> getRecentActivities({int limit = 10}) async {
    final response = await _api.get('/activity-log', queryParameters: {'limit': limit});
    if (response.statusCode == 200 && response.data['success'] == true) {
      final logs = response.data['logs'] as List<dynamic>? ?? [];
      return logs.map((e) => RecentActivityModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load recent activities');
  }

  Future<Map<String, dynamic>> getPaginatedActivities({int page = 1, int limit = 20}) async {
    final response = await _api.get('/activity-log', queryParameters: {'page': page, 'limit': limit});
    if (response.statusCode == 200 && response.data['success'] == true) {
      final logsData = response.data['logs'] as List<dynamic>? ?? [];
      final logs = logsData.map((e) => RecentActivityModel.fromJson(e)).toList();
      return {
        'logs': logs,
        'totalPages': response.data['total_pages'] ?? 1,
        'total': response.data['total'] ?? 0,
      };
    }
    throw Exception('Failed to load activity logs');
  }

  Future<Map<String, dynamic>> getPaginatedNotifications({int page = 1, int limit = 20}) async {
    final response = await _api.get('/notifications', queryParameters: {'page': page, 'limit': limit});
    if (response.statusCode == 200 && response.data['success'] == true) {
      final logsData = response.data['notifications'] as List<dynamic>? ?? [];
      final notifications = logsData.map((e) => RecentActivityModel.fromJson(e)).toList();
      return {
        'notifications': notifications,
        'totalPages': response.data['total_pages'] ?? 1,
        'total': response.data['total'] ?? 0,
      };
    }
    throw Exception('Failed to load notifications');
  }
}
