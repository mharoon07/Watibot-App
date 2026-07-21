import 'package:get/get.dart';
import 'package:watibot/modules/home/models/dashboard_stats_model.dart';
import 'package:watibot/modules/home/models/recent_activity_model.dart';
import 'package:watibot/modules/home/models/usage_overview_model.dart';
import 'package:watibot/modules/home/models/workspace_status_model.dart';
import 'package:watibot/modules/home/repositories/home_repository.dart';
import 'package:watibot/core/services/api_service.dart';
import 'package:watibot/core/services/storage_service.dart';
import 'package:watibot/modules/home/routes/home_routes.dart';

class HomeController extends GetxController {
  final HomeRepository _repository;
  final StorageService _storage = Get.find<StorageService>();

  HomeController(this._repository);
  final loading = true.obs;
  final selectedTab = 0.obs;

  final RxString userName = ''.obs;
  final RxString userAvatar = ''.obs;
  final RxString accountEmail = ''.obs;

  final Rx<DashboardStatsModel?> dashboardStats = Rx<DashboardStatsModel?>(null);
  final Rx<WorkspaceStatusModel?> workspaceStatus = Rx<WorkspaceStatusModel?>(null);
  final Rx<UsageOverviewModel?> usageOverview = Rx<UsageOverviewModel?>(null);
  final Rx<List<RecentActivityModel>> recentActivities = Rx<List<RecentActivityModel>>([]);

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    loading.value = true;
    userName.value = _storage.userName ?? 'User';
    userAvatar.value = _storage.userAvatar ?? '';
    try {
      await Future.wait([
        loadDashboardData(),
        loadUsage(),
        loadRecentActivities(),
      ]);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load dashboard data fully');
    } finally {
      loading.value = false;
    }
  }

  Future<void> refreshDashboard() async {
    try {
      await Future.wait([
        loadDashboardData(),
        loadUsage(),
        loadRecentActivities(),
      ]);
    } catch (e) {
      Get.snackbar('Error', 'Failed to refresh dashboard data');
    }
  }

  Future<void> loadDashboardData() async {
    try {
      final rawData = await _repository.getDashboardData();
      dashboardStats.value = DashboardStatsModel.fromJson(rawData['dashboard'] ?? {});
      workspaceStatus.value = WorkspaceStatusModel.fromJson(rawData['project'] ?? {});
      accountEmail.value = workspaceStatus.value?.email ?? userName.value;
    } catch (e) {
      print('Failed to load dashboard data: $e');
    }
  }

  Future<void> loadUsage() async {
    try {
      usageOverview.value = await _repository.getUsageOverview();
    } catch (e) {
      print('Failed to load usage overview: $e');
    }
  }

  Future<void> loadRecentActivities() async {
    try {
      recentActivities.value = await _repository.getRecentActivities();
    } catch (e) {
      print('Failed to load recent activities: $e');
    }
  }

  void changeTab(int index) {
    if (index == selectedTab.value) return;
    selectedTab.value = index;
   }

  void openNotifications() {
    Get.toNamed(HomeRoutes.notifications);
  }

  void openProfile() {
    Get.snackbar('Profile', 'Profile page coming soon');
  }
}
