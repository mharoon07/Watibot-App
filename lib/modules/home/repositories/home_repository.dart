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
}
