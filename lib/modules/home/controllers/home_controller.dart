import 'package:get/get.dart';
import 'package:watibot/modules/home/models/dashboard_model.dart';
import 'package:watibot/modules/home/repositories/home_repository.dart';

class HomeController extends GetxController {
  final HomeRepository _repository;

  HomeController(this._repository);

  final Rx<DashboardModel?> dashboardData = Rx<DashboardModel?>(null);
  final loading = true.obs;
  final selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    loading.value = true;
    try {
      final data = await _repository.getDashboardData();
      dashboardData.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load dashboard data');
    } finally {
      loading.value = false;
    }
  }

  Future<void> refreshDashboard() async {
    try {
      final data = await _repository.getDashboardData();
      dashboardData.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to refresh dashboard data');
    }
  }

  void changeTab(int index) {
    if (index == selectedTab.value) return;
    selectedTab.value = index;
    // In a real app, you would navigate or change views based on tab
  }

  void openNotifications() {
    Get.snackbar('Notifications', 'No new notifications');
  }

  void openProfile() {
    Get.snackbar('Profile', 'Profile page coming soon');
  }
}
