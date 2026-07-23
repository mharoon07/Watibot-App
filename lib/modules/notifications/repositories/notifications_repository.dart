import 'package:get/get.dart';
import 'package:watibot/core/services/api_service.dart';
import 'package:watibot/modules/notifications/models/notification_model.dart';

class NotificationsRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 30,
    String tab = 'all',
    int? lastReadAt,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (tab != 'all') 'tab': tab,
      };

      final response = await _apiService.get('/notifications', queryParameters: queryParams);
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final notificationsList = (data['notifications'] as List<dynamic>?)
                ?.map((e) => NotificationItemModel.fromJson(e as Map<String, dynamic>, lastReadAt: lastReadAt))
                .toList() ??
            [];

        final summaryList = (data['summary'] as List<dynamic>?)
                ?.map((e) => NotificationModuleSummaryModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];

        return {
          'success': true,
          'total': data['total'] ?? notificationsList.length,
          'unread_count': data['unread_count'] ?? 0,
          'notifications': notificationsList,
          'summary': summaryList,
        };
      }
      return {'success': false, 'notifications': <NotificationItemModel>[], 'summary': <NotificationModuleSummaryModel>[], 'total': 0};
    } catch (e) {
      return {'success': false, 'error': ApiService.extractErrorMessage(e, 'Failed to fetch notifications'), 'notifications': <NotificationItemModel>[], 'summary': <NotificationModuleSummaryModel>[], 'total': 0};
    }
  }

  Future<Map<String, dynamic>> markAsRead({String? id, bool markAll = false}) async {
    try {
      final data = <String, dynamic>{};
      if (markAll) {
        data['mark_all'] = true;
      } else if (id != null) {
        data['id'] = id;
      } else {
        return {'success': false, 'error': 'Invalid arguments'};
      }

      final response = await _apiService.put('/notifications', data: data);
      final responseData = response.data;
      if (responseData is Map<String, dynamic> && responseData['success'] == true) {
        return {'success': true};
      }
      return {'success': false, 'error': 'Failed to mark as read'};
    } catch (e) {
      return {'success': false, 'error': ApiService.extractErrorMessage(e, 'Failed to mark as read')};
    }
  }
}
