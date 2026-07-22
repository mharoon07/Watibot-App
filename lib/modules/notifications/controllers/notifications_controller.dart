import 'package:get/get.dart';
import 'package:watibot/core/services/storage_service.dart';
import 'package:watibot/modules/notifications/models/notification_model.dart';
import 'package:watibot/modules/notifications/repositories/notifications_repository.dart';

class NotificationsController extends GetxController {
  final NotificationsRepository _repository = NotificationsRepository();
  final StorageService _storage = Get.find<StorageService>();

  final RxList<NotificationItemModel> notifications = <NotificationItemModel>[].obs;
  final RxList<NotificationModuleSummaryModel> summary = <NotificationModuleSummaryModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxInt unreadCount = 0.obs;
  final RxString selectedTab = 'all'.obs;

  int? get _lastReadAt => _storage.getInt('notifications_last_read_at');

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    final res = await _repository.getNotifications(
      tab: selectedTab.value,
      lastReadAt: _lastReadAt,
    );
    isLoading.value = false;

    if (res['success'] == true) {
      notifications.value = List<NotificationItemModel>.from(res['notifications']);
      summary.value = List<NotificationModuleSummaryModel>.from(res['summary']);
      
      // Calculate unread items
      final lastRead = _lastReadAt ?? 0;
      final unreadItems = notifications.where((n) => (n.createdAt ?? 0) > lastRead).length;
      unreadCount.value = unreadItems;
    }
  }

  void onTabChanged(String tab) {
    selectedTab.value = tab;
    fetchNotifications();
  }

  void markAllAsRead() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _storage.setInt('notifications_last_read_at', now);


    for (var item in notifications) {
      item.isRead = true;
    }
    notifications.refresh();
    unreadCount.value = 0;
    Get.snackbar('Notifications', 'All notifications marked as read', snackPosition: SnackPosition.BOTTOM);
  }

  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index].isRead = true;
      notifications.refresh();
      if (unreadCount.value > 0) unreadCount.value--;
    }
  }
}
