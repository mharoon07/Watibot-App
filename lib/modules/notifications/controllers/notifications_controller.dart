import 'package:flutter/material.dart';
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
      
      // Calculate unread items from API
      unreadCount.value = res['unread_count'] ?? 0;
    }
  }

  void onTabChanged(String tab) {
    selectedTab.value = tab;
    fetchNotifications();
  }

  Future<void> markAllAsRead() async {
    // Optimistic UI Update
    for (var item in notifications) {
      item.isRead = true;
    }
    final previousUnread = unreadCount.value;
    unreadCount.value = 0;
    notifications.refresh();

    // API Call
    final res = await _repository.markAsRead(markAll: true);
    
    if (res['success'] == true) {
      // Legacy fallback just in case
      final now = DateTime.now().millisecondsSinceEpoch;
      _storage.setInt('notifications_last_read_at', now);
      Get.snackbar('Notifications', 'All notifications marked as read', snackPosition: SnackPosition.BOTTOM);
    } else {
      // Revert Optimistic Update
      for (var item in notifications) {
        item.isRead = false; // Note: In a real app we'd keep track of what was read before, but marking all as unread is safer here if it fails
      }
      unreadCount.value = previousUnread;
      notifications.refresh();
      Get.snackbar('Error', res['error'] ?? 'Failed to mark notifications as read', snackPosition: SnackPosition.BOTTOM, backgroundColor: Color(0xFFFEF2F2), colorText: Color(0xFF991B1B));
    }
  }

  Future<void> markAsRead(String id) async {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index == -1 || notifications[index].isRead) return;

    // Optimistic UI Update
    notifications[index].isRead = true;
    notifications.refresh();
    if (unreadCount.value > 0) unreadCount.value--;

    // API Call
    final res = await _repository.markAsRead(id: id);
    
    if (res['success'] != true) {
      // Revert Optimistic Update
      notifications[index].isRead = false;
      notifications.refresh();
      unreadCount.value++;
      Get.snackbar('Error', res['error'] ?? 'Failed to mark notification as read', snackPosition: SnackPosition.BOTTOM, backgroundColor: Color(0xFFFEF2F2), colorText: Color(0xFF991B1B));
    }
  }
}
